import Foundation

struct NoteItem: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tagsRaw: String  // Comma-separated tags
    var isPinned: Bool
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        title: String,
        content: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        tagsRaw: String = "",
        isPinned: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagsRaw = tagsRaw
        self.isPinned = isPinned
    }
    
    var tags: [String] {
        tagsRaw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var preview: String {
        String(content.prefix(120))
    }
}
