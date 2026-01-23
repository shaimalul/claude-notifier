import Foundation
import Network

final class HTTPServer: HTTPServerProtocol {
    private let port: UInt16
    private var listener: NWListener?
    private let requestHandler: RequestHandlerProtocol
    private let queue = DispatchQueue(label: "com.claudenotifier.httpserver")
    private let logger: LoggerProtocol

    init(
        port: UInt16 = AppConfig.httpPort,
        onNotification: @escaping (ClaudeNotification) -> Void,
        logger: LoggerProtocol = Logger.shared
    ) {
        self.port = port
        self.logger = logger
        self.requestHandler = RequestHandler(onNotification: onNotification, logger: logger)
    }

    func start() {
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            guard let nwPort = NWEndpoint.Port(rawValue: port) else {
                logger.log("Invalid port: \(port)", category: "HTTP")
                return
            }

            listener = try NWListener(using: parameters, on: nwPort)
            listener?.stateUpdateHandler = { [weak self] state in
                self?.handleStateUpdate(state)
            }
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: queue)
        } catch {
            logger.log("Failed to start HTTP server: \(error)", category: "HTTP")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleStateUpdate(_ state: NWListener.State) {
        switch state {
        case .ready:
            logger.log("HTTP Server listening on port \(port)", category: "HTTP")
        case .failed(let error):
            logger.log("HTTP Server failed: \(error)", category: "HTTP")
        case .cancelled:
            logger.log("HTTP Server cancelled", category: "HTTP")
        default:
            break
        }
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            if case .ready = state {
                self?.receiveData(from: connection)
            }
        }
        connection.start(queue: queue)
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty,
               let request = String(data: data, encoding: .utf8) {
                self?.requestHandler.handle(request: request, connection: connection)
            }

            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }
}
