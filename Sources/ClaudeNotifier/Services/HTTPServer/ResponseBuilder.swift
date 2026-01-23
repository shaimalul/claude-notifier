import Foundation

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
        case 500: "Internal Server Error"
        default: "Unknown"
        }
    }
}
