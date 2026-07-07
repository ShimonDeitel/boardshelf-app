import Foundation

struct Game: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var players: Int
    var lastPlayed: Date
    var notes: String
}
