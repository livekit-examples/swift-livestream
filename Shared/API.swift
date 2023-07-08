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
    var authToken: String?

    init(apiBaseURLString: String) {
        guard let url = URL(string: apiBaseURLString) else {
            fatalError("API Endpoint URL format is incorrect")
        }
        self.apiBaseURL = url
    }

    public func reset() {
        self.authToken = nil
    }

    private func prepareRequest(apiPath: String, data: Encodable? = nil) async throws -> URLRequest {

        guard var components = URLComponents(url: apiBaseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.url
        }

        components.path = apiPath

        guard let url = components.url else {
            throw APIError.url
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let data = data {
            let jsonData = try encoder.encode(data)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let authToken = authToken {
            request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
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
        let res: CreateStreamResponse = try await post(apiPath: "/api/create_stream", data: r)
        self.authToken = res.authToken
        return res
    }

    public func joinStream(_ r: JoinStreamRequest) async throws -> JoinStreamResponse {
        let res: JoinStreamResponse = try await post(apiPath: "/api/join_stream", data: r)
        self.authToken = res.authToken
        return res
    }

    public func stopStream() async throws {
        assert(authToken != nil)
        try await post(apiPath: "/api/stop_stream")
    }

    public func inviteToStage(identity: String) async throws {
        assert(authToken != nil)
        let p = InviteToStageRequest(identity: identity)
        try await post(apiPath: "/api/invite_to_stage", data: p)
    }

    public func removeFromStage(identity: String? = nil) async throws {
        assert(authToken != nil)
        let p = InviteToStageRequest(identity: identity)
        try await post(apiPath: "/api/remove_from_stage", data: p)
    }

    public func raiseHand() async throws {
        assert(authToken != nil)
        try await post(apiPath: "/api/raise_hand")
    }
}
