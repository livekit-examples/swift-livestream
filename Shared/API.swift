import SwiftUI
import LiveKit

enum APIError: Error {
    case url
}

class API {

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let apiBaseURL: URL

    init(apiBaseURLString: String) {

        guard let url = URL(string: apiBaseURLString) else {
            fatalError("API Endpoint URL format is incorrect")
        }

        self.apiBaseURL = url
    }

    private func post<T: Encodable, U: Decodable>(apiPath: String, data: T) async throws -> U {

        let jsonData = try encoder.encode(data)

        guard var components = URLComponents(url: apiBaseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.url

        }

        components.path = apiPath

        guard let url = components.url else {
            throw APIError.url
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decoder.decode(U.self, from: data)
    }

    public func createStream(_ r: CreateStream) async throws -> CreateStreamResponse {
        try await post(apiPath: "/api/create_stream", data: r)
    }
}
