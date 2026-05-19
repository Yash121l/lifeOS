import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    
    @State private var title: String
    @State private var content: String
    @State private var tagsText: String
    @State private var isPinned: Bool
    @State private var hasChanges = false
    
    private let existingNote: NoteItem?
    private var userId: String { authService.currentUser?.uid ?? "" }
    private var isNew: Bool { existingNote == nil }
    
    init(note: NoteItem?) {
        self.existingNote = note
        _title = State(initialValue: note?.title ?? "")
        // Strip any HTML tags that may have been stored by older rich-text editors
        _content = State(initialValue: (note?.content ?? "").strippedHTML)
        _tagsText = State(initialValue: note?.tagsRaw ?? "")
        _isPinned = State(initialValue: note?.isPinned ?? false)
    }
    
    private var tags: [String] {
        tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Note title", text: $title)
                        .font(.headline)
                        .onChange(of: title) { _, _ in hasChanges = true }
                    
                    TextField("Tags (comma separated)", text: $tagsText)
                        .onChange(of: tagsText) { _, _ in hasChanges = true }
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 250)
                        .onChange(of: content) { _, _ in hasChanges = true }
                }
                
                if !isNew {
                    Section {
                        Button(role: .destructive) {
                            DSHaptics.error()
                            Task {
                                try? await store.deleteNote(existingNote!.id, userId: userId)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Note")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        DSHaptics.selection()
                        isPinned.toggle()
                        hasChanges = true
                    } label: {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15))
                            .foregroundStyle(isPinned ? DSColor.warning : DSColor.textTertiary)
                    }
                    
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func removeTag(_ tag: String) {
        var currentTags = tags
        currentTags.removeAll { $0 == tag }
        tagsText = currentTags.joined(separator: ", ")
        hasChanges = true
    }
    
    private func saveNote() {
        DSHaptics.success()
        var note = existingNote ?? NoteItem(title: title, content: content)
        note.title = title
        note.content = content
        note.tagsRaw = tagsText
        note.isPinned = isPinned
        note.updatedAt = .now
        
        Task {
            try? await store.saveNote(note, userId: userId)
            dismiss()
        }
    }
}
