import Foundation
import Network

protocol RequestHandlerProtocol {
    func handle(request: String, connection: NWConnection)
}

final class RequestHandler: RequestHandlerProtocol {
    private let onNotification: (ClaudeNotification) -> Void
    private let responseBuilder: ResponseBuilderProtocol
    private let logger: LoggerProtocol

    // HTTP validation constants
    private let validMethods = ["GET", "POST", "HEAD", "OPTIONS"]
    private let maxJSONPayloadBytes = 8192

    init(
        onNotification: @escaping (ClaudeNotification) -> Void,
        responseBuilder: ResponseBuilderProtocol = ResponseBuilder(),
        logger: LoggerProtocol = Logger.shared
    ) {
        self.onNotification = onNotification
        self.responseBuilder = responseBuilder
        self.logger = logger
    }

    func handle(request: String, connection: NWConnection) {
        guard let parsed = parseRequest(request, connection: connection) else { return }
        routeRequest(method: parsed.method, path: parsed.path, request: request, connection: connection)
    }

    private func parseRequest(_ request: String, connection: NWConnection) -> (method: String, path: String)? {
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid request\"}")
            return nil
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count == 3 else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid request line\"}")
            return nil
        }

        guard parts[2].hasPrefix("HTTP/1.") else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Unsupported HTTP version\"}")
            return nil
        }

        guard validMethods.contains(parts[0]) else {
            sendResponse(connection: connection, statusCode: 405, body: "{\"error\":\"Method not allowed\"}")
            return nil
        }

        guard !parts[1].contains(".."), parts[1].hasPrefix("/") else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid path\"}")
            return nil
        }

        return (parts[0], parts[1])
    }

    private func routeRequest(method: String, path: String, request: String, connection: NWConnection) {
        switch (method, path) {
        case ("POST", "/notify"):
            handleNotifyRequest(request: request, connection: connection)
        case ("GET", "/health"):
            sendResponse(connection: connection, statusCode: 200, body: "{\"status\":\"ok\"}")
        default:
            sendResponse(connection: connection, statusCode: 404, body: "{\"error\":\"Not found\"}")
        }
    }

    private func handleNotifyRequest(request: String, connection: NWConnection) {
        let parts = request.components(separatedBy: "\r\n\r\n")
        guard parts.count >= 2 else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Missing body\"}")
            return
        }

        let bodyString = parts[1]

        // Validate payload size
        guard let jsonData = bodyString.data(using: .utf8),
              jsonData.count <= maxJSONPayloadBytes
        else {
            sendResponse(connection: connection, statusCode: 413, body: "{\"error\":\"Payload too large\"}")
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
            logger.log("Failed to parse notification: Invalid JSON format", category: "HTTP")
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid JSON\"}")
        }
    }

    private func sendResponse(connection: NWConnection, statusCode: Int, body: String) {
        guard let responseData = responseBuilder.build(statusCode: statusCode, body: body) else {
            connection.cancel()
            return
        }

        connection.send(content: responseData, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
