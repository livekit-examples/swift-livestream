struct InviteToStageRequest: Codable {
    let identity: String?
}

struct RemoveFromStageRequest: Codable {
    let identity: String
}
