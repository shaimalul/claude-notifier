import Foundation
import Network

protocol RequestHandlerProtocol {
    func handle(request: String, connection: NWConnection)
}

final class RequestHandler: RequestHandlerProtocol {
    private let onNotification: (ClaudeNotification) -> Void
    private let responseBuilder: ResponseBuilderProtocol
    private let logger: LoggerProtocol

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
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid request\"}")
            return
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid request\"}")
            return
        }

        let method = parts[0]
        let path = parts[1]

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
        guard parts.count >= 2,
              let jsonData = parts[1].data(using: .utf8)
        else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Missing body\"}")
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
            logger.log("Failed to parse notification: \(error)", category: "HTTP")
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
