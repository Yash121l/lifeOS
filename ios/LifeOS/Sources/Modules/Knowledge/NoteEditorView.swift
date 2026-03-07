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
        _content = State(initialValue: note?.content ?? "")
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
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    // Title
                    TextField("Note title...", text: $title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .onChange(of: title) { _, _ in hasChanges = true }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        // Existing tags
                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: DSSpacing.xs) {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(spacing: DSSpacing.xxs) {
                                            Text("#\(tag)")
                                                .font(DSFont.caption())
                                                .foregroundStyle(DSColor.accent)
                                            
                                            Button {
                                                removeTag(tag)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 8, weight: .bold))
                                                    .foregroundStyle(DSColor.textTertiary)
                                            }
                                        }
                                        .padding(.horizontal, DSSpacing.sm)
                                        .padding(.vertical, DSSpacing.xxs + 1)
                                        .background(
                                            Capsule()
                                                .fill(DSColor.accent.opacity(0.1))
                                                .overlay(Capsule().stroke(DSColor.accent.opacity(0.2), lineWidth: 1))
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Tag input
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "tag")
                                .font(.system(size: 13))
                                .foregroundStyle(DSColor.textTertiary)
                            TextField("Add tags (comma separated)", text: $tagsText)
                                .font(DSFont.caption())
                                .foregroundStyle(DSColor.textSecondary)
                                .onChange(of: tagsText) { _, _ in hasChanges = true }
                        }
                        .padding(DSSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                .fill(DSColor.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadius.sm)
                                        .stroke(DSColor.cardBorder, lineWidth: 1)
                                )
                        )
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(DSColor.cardBorder)
                        .frame(height: 1)
                    
                    // Content editor
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Start writing...")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .font(DSFont.body())
                            .foregroundStyle(DSColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 300)
                            .onChange(of: content) { _, _ in hasChanges = true }
                    }
                    
                    // Delete for existing
                    if !isNew {
                        DSButton("Delete Note", icon: "trash", style: .destructive, isFullWidth: true) {
                            DSHaptics.error()
                            Task {
                                try? await store.deleteNote(existingNote!.id, userId: userId)
                                dismiss()
                            }
                        }
                        .padding(.top, DSSpacing.lg)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle(isNew ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColor.textSecondary)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        DSHaptics.selection()
                        isPinned.toggle()
                        hasChanges = true
                    } label: {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15))
                            .foregroundStyle(isPinned ? DSColor.amber : DSColor.textTertiary)
                    }
                    
                    Button("Save") { saveNote() }
                        .font(DSFont.headline())
                        .foregroundStyle(hasChanges ? DSColor.accent : DSColor.textTertiary)
                        .disabled(!hasChanges)
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
