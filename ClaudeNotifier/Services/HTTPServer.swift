import Foundation
import Network

class HTTPServer {
    private let port: UInt16
    private var listener: NWListener?
    private let onNotification: (ClaudeNotification) -> Void
    private let queue = DispatchQueue(label: "com.claudenotifier.httpserver")

    init(port: UInt16, onNotification: @escaping (ClaudeNotification) -> Void) {
        self.port = port
        self.onNotification = onNotification
    }

    func start() {
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("HTTP Server listening on port \(self?.port ?? 0)")
                case .failed(let error):
                    print("HTTP Server failed: \(error)")
                case .cancelled:
                    print("HTTP Server cancelled")
                default:
                    break
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }

            listener?.start(queue: queue)
        } catch {
            print("Failed to start HTTP server: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                self.receiveData(from: connection)
            case .failed(let error):
                print("Connection failed: \(error)")
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.processRequest(data: data, connection: connection)
            }

            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }

    private func processRequest(data: Data, connection: NWConnection) {
        guard let request = String(data: data, encoding: .utf8) else {
            sendResponse(connection: connection, statusCode: 400, body: "Invalid request")
            return
        }

        // Parse HTTP request
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendResponse(connection: connection, statusCode: 400, body: "Invalid request")
            return
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(connection: connection, statusCode: 400, body: "Invalid request")
            return
        }

        let method = parts[0]
        let path = parts[1]

        // Handle POST /notify
        if method == "POST" && path == "/notify" {
            handleNotifyRequest(request: request, connection: connection)
        } else if method == "GET" && path == "/health" {
            sendResponse(connection: connection, statusCode: 200, body: "{\"status\":\"ok\"}")
        } else {
            sendResponse(connection: connection, statusCode: 404, body: "Not found")
        }
    }

    private func handleNotifyRequest(request: String, connection: NWConnection) {
        // Find JSON body (after empty line)
        let parts = request.components(separatedBy: "\r\n\r\n")
        guard parts.count >= 2,
              let jsonData = parts[1].data(using: .utf8) else {
            sendResponse(connection: connection, statusCode: 400, body: "Missing body")
            return
        }

        do {
            let payload = try JSONDecoder().decode(NotificationPayload.self, from: jsonData)
            let notification = payload.toClaudeNotification()

            DispatchQueue.main.async { [weak self] in
                self?.onNotification(notification)
            }

            sendResponse(connection: connection, statusCode: 200, body: "{\"status\":\"received\"}")
        } catch {
            print("Failed to parse notification: \(error)")
            sendResponse(connection: connection, statusCode: 400, body: "Invalid JSON: \(error.localizedDescription)")
        }
    }

    private func sendResponse(connection: NWConnection, statusCode: Int, body: String) {
        let statusText: String
        switch statusCode {
        case 200: statusText = "OK"
        case 400: statusText = "Bad Request"
        case 404: statusText = "Not Found"
        default: statusText = "Unknown"
        }

        let response = """
        HTTP/1.1 \(statusCode) \(statusText)\r
        Content-Type: application/json\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """

        if let responseData = response.data(using: .utf8) {
            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }
}
