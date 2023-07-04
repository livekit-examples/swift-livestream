import SwiftUI
import LiveKit

enum APIError: Error {
    case url
    case fail
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

    private func prepareRequest(apiPath: String, data: Encodable? = nil, method: String = "POST") async throws -> URLRequest {
        guard var components = URLComponents(url: apiBaseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.url
        }

        components.path = apiPath

        guard let url = components.url else {
            throw APIError.url
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let data = data {
            let jsonData = try encoder.encode(data)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }

    private func post<T: Encodable, U: Decodable>(apiPath: String, data: T) async throws -> U {
        let request = try await prepareRequest(apiPath: apiPath, data: data)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(U.self, from: data)
    }

    private func post<T: Encodable>(apiPath: String, data: T) async throws {
        let request = try await prepareRequest(apiPath: apiPath, data: data)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200 else {
            throw APIError.fail
        }
    }

    private func post(apiPath: String) async throws {
        let request = try await prepareRequest(apiPath: apiPath)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200 else {
            throw APIError.fail
        }
    }

    public func createStream(_ r: CreateStreamRequest) async throws -> CreateStreamResponse {
        try await post(apiPath: "/api/create_stream", data: r)
    }

    public func joinStream(_ r: JoinStreamRequest) async throws -> JoinStreamResponse {
        try await post(apiPath: "/api/join_stream", data: r)
    }

    public func stopStream() async throws {
        try await post(apiPath: "/api/stop_stream")
    }

    public func inviteToStage(identity: String) async throws {
        let p = InviteToStageRequest(identity: identity)
        try await post(apiPath: "/api/invited_to_stage", data: p)
    }

    public func removeFromStage(identity: String) async throws {
        let p = InviteToStageRequest(identity: identity)
        try await post(apiPath: "/api/remove_from_stage", data: p)
    }

    public func raiseHand() async throws {
        try await post(apiPath: "/api/raise_hand")
    }
}
