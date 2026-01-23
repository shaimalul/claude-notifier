import Foundation
import Network

final class HTTPServer: HTTPServerProtocol {
    private let port: UInt16
    private var listener: NWListener?
    private let requestHandler: RequestHandlerProtocol
    private let queue = DispatchQueue(label: "com.claudenotifier.httpserver")
    private let logger: LoggerProtocol

    // Rate limiting properties
    private let maxConcurrentConnections = 10
    private var activeConnectionCount = 0
    private let connectionLock = NSLock()
    private let requestTimeout: TimeInterval = 5.0

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
        case let .failed(error):
            logger.log("HTTP Server failed: \(error)", category: "HTTP")
        case .cancelled:
            logger.log("HTTP Server cancelled", category: "HTTP")
        default:
            break
        }
    }

    private func handleConnection(_ connection: NWConnection) {
        // Rate limiting: reject if too many concurrent connections
        connectionLock.lock()
        guard activeConnectionCount < maxConcurrentConnections else {
            connectionLock.unlock()
            logger.log("Rejected connection: max limit reached", category: "HTTP")
            connection.cancel()
            return
        }
        activeConnectionCount += 1
        connectionLock.unlock()

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.receiveData(from: connection)
            case .cancelled, .failed:
                self?.decrementConnectionCount()
            default:
                break
            }
        }
        connection.start(queue: queue)

        // Request timeout
        DispatchQueue.global().asyncAfter(deadline: .now() + requestTimeout) { [weak connection] in
            connection?.cancel()
        }
    }

    private func decrementConnectionCount() {
        connectionLock.lock()
        activeConnectionCount = max(0, activeConnectionCount - 1)
        connectionLock.unlock()
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data, !data.isEmpty,
               let request = String(data: data, encoding: .utf8)
            {
                self?.requestHandler.handle(request: request, connection: connection)
            }

            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }
}
