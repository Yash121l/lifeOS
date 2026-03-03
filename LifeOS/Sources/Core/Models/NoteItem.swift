import Foundation
import SwiftData

@Model
final class NoteItem {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tagsRaw: String  // Comma-separated tags
    var isPinned: Bool
    
    init(
        title: String,
        content: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        tagsRaw: String = "",
        isPinned: Bool = false
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagsRaw = tagsRaw
        self.isPinned = isPinned
    }
    
    var tags: [String] {
        get {
            tagsRaw.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        set {
            tagsRaw = newValue.joined(separator: ",")
        }
    }
    
    var preview: String {
        String(content.prefix(120))
    }
}
