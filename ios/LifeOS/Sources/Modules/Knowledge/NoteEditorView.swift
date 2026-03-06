import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var note: NoteItem
    @State private var newTag: String = ""
    @FocusState private var titleFocused: Bool
    
    private var isNew: Bool {
        note.modelContext == nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                // Title
                TextField("Title", text: $note.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DSColor.textPrimary)
                    .tint(DSColor.accent)
                    .focused($titleFocused)
                
                Divider().overlay(DSColor.cardBorder)
                
                // Tags
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Tags")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    FlowLayout(spacing: DSSpacing.xs) {
                        ForEach(note.tags, id: \.self) { tag in
                            HStack(spacing: DSSpacing.xxs) {
                                Text(tag)
                                    .font(DSFont.captionSmall())
                                
                                Button {
                                    var current = note.tags
                                    current.removeAll { $0 == tag }
                                    note.tags = current
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                }
                            }
                            .foregroundStyle(DSColor.accent)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xxs)
                            .background(
                                Capsule().fill(DSColor.accent.opacity(0.15))
                            )
                        }
                        
                        // Add tag input
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: "plus")
                                .font(.system(size: 10))
                                .foregroundStyle(DSColor.textTertiary)
                            
                            TextField("Add tag", text: $newTag)
                                .font(DSFont.captionSmall())
                                .foregroundStyle(DSColor.textPrimary)
                                .frame(width: 60)
                                .onSubmit {
                                    addTag()
                                }
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(
                            Capsule()
                                .stroke(DSColor.cardBorder, lineWidth: 0.5)
                        )
                    }
                }
                
                Divider().overlay(DSColor.cardBorder)
                
                // Pin toggle
                HStack {
                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                        .foregroundStyle(note.isPinned ? DSColor.warning : DSColor.textTertiary)
                    
                    Text("Pin note")
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $note.isPinned)
                        .tint(DSColor.warning)
                        .labelsHidden()
                }
                
                Divider().overlay(DSColor.cardBorder)
                
                // Content editor
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Content")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    TextEditor(text: $note.content)
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                        .tint(DSColor.accent)
                        .frame(minHeight: 200)
                        .scrollContentBackground(.hidden)
                }
            }
            .padding(DSSpacing.md)
        }
        .background(DSColor.background)
        .navigationTitle(isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(DSColor.textSecondary)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    DSHaptics.success()
                    note.updatedAt = .now
                    if isNew {
                        modelContext.insert(note)
                    }
                    dismiss()
                }
                .foregroundStyle(note.title.isEmpty ? DSColor.textTertiary : DSColor.accent)
                .fontWeight(.semibold)
                .disabled(note.title.isEmpty)
            }
        }
        .onAppear {
            if isNew {
                titleFocused = true
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !note.tags.contains(tag) else { return }
        var current = note.tags
        current.append(tag)
        note.tags = current
        newTag = ""
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        let finalSize = CGSize(width: maxWidth, height: currentY + lineHeight)
        return (finalSize, positions)
    }
}
