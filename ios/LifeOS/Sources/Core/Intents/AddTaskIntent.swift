import AppIntents
import Foundation

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task to LifeOS"
    static var description = IntentDescription("Creates a new task in LifeOS.")

    @Parameter(title: "Task Title")
    var taskTitle: String

    @MainActor
    func perform() async throws -> some IntentResult {
        let msg = "Added Task: \(taskTitle)"
        return .result(dialog: IntentDialog(stringLiteral: msg))
    }
}

struct LifeOSShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Create a task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "checklist"
        )
    }
}
