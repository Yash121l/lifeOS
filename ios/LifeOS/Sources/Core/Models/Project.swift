import Foundation
import SwiftData

@Model
final class Project {
    var name: String
    var colorHex: String
    
    @Relationship(deleteRule: .cascade)
    var tasks: [TaskItem]?
    
    init(name: String, colorHex: String = "#0000FF") {
        self.name = name
        self.colorHex = colorHex
    }
}
