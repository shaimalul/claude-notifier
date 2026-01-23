import Foundation

enum HTTPStatus: Int {
    case ok = 200
    case badRequest = 400
    case notFound = 404
    case methodNotAllowed = 405
    case payloadTooLarge = 413
    case internalServerError = 500

    var reasonPhrase: String {
        switch self {
        case .ok: "OK"
        case .badRequest: "Bad Request"
        case .notFound: "Not Found"
        case .methodNotAllowed: "Method Not Allowed"
        case .payloadTooLarge: "Payload Too Large"
        case .internalServerError: "Internal Server Error"
        }
    }
}

protocol ResponseBuilderProtocol {
    func build(statusCode: Int, body: String) -> Data?
}

final class ResponseBuilder: ResponseBuilderProtocol {
    func build(statusCode: Int, body: String) -> Data? {
        let statusText = statusTextFor(code: statusCode)

        let response = """
        HTTP/1.1 \(statusCode) \(statusText)\r
        Content-Type: application/json\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """

        return response.data(using: .utf8)
    }

    private func statusTextFor(code: Int) -> String {
        switch code {
        case 200: "OK"
        case 400: "Bad Request"
        case 404: "Not Found"
        case 405: "Method Not Allowed"
        case 413: "Payload Too Large"
        case 500: "Internal Server Error"
        default: "Unknown"
        }
    }
}
