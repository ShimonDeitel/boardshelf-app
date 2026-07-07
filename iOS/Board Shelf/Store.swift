import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Game] = []
    @Published var isPro: Bool = false

    static let freeLimit = 25

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("boardshelf", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Game) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Game) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Game) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static var seedData: [Game] {
        [
        Game(id: UUID(), title: "Catan", players: 4, lastPlayed: ISO8601DateFormatter().date(from: "2026-06-01T00:00:00Z") ?? Date(), notes: "Great with 4"),
        Game(id: UUID(), title: "Wingspan", players: 3, lastPlayed: ISO8601DateFormatter().date(from: "2026-06-10T00:00:00Z") ?? Date(), notes: "Solo mode too"),
        Game(id: UUID(), title: "Codenames", players: 6, lastPlayed: ISO8601DateFormatter().date(from: "2026-06-15T00:00:00Z") ?? Date(), notes: "Party favorite")
        ]
    }
}
