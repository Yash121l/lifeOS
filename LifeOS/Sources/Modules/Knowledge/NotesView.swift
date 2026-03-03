import SwiftUI
import SwiftData

enum NotesViewMode: String, CaseIterable {
    case list = "list.bullet"
    case grid = "square.grid.2x2"
}

struct NotesView: View {
    @Query(sort: \NoteItem.updatedAt, order: .reverse) private var notes: [NoteItem]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var viewMode: NotesViewMode = .list
    @State private var selectedTag: String?
    @State private var showEditor = false
    @State private var editingNote: NoteItem?
    
    private var filteredNotes: [NoteItem] {
        var result = notes
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        // Sort pinned first
        return result.sorted { ($0.isPinned ? 1 : 0) > ($1.isPinned ? 1 : 0) }
    }
    
    private var allTags: [String] {
        Array(Set(notes.flatMap(\.tags))).sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                searchBar
                
                // Tags
                if !allTags.isEmpty {
                    tagsPicker
                }
                
                // Content
                if filteredNotes.isEmpty {
                    emptyState
                } else {
                    contentView
                }
            }
            .background(DSColor.background)
            .navigationTitle("Knowledge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            DSHaptics.selection()
                            withAnimation(DSAnimation.springQuick) {
                                viewMode = viewMode == .list ? .grid : .list
                            }
                        } label: {
                            Image(systemName: viewMode.rawValue)
                                .font(.system(size: 16))
                                .foregroundStyle(DSColor.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(DSColor.surfaceLight))
                        }
                        
                        Button {
                            editingNote = nil
                            showEditor = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(DSColor.accent)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    NoteEditorView(note: editingNote ?? NoteItem(title: "", content: ""))
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Search
    
    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(DSColor.textTertiary)
            
            TextField("Search notes...", text: $searchText)
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textPrimary)
                .tint(DSColor.accent)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(DSColor.cardBorder, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, DSSpacing.md)
    }
    
    // MARK: - Tags
    
    private var tagsPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                // All tag
                tagChip(label: "All", isSelected: selectedTag == nil) {
                    selectedTag = nil
                }
                
                ForEach(allTags, id: \.self) { tag in
                    tagChip(label: tag, isSelected: selectedTag == tag) {
                        selectedTag = selectedTag == tag ? nil : tag
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
    }
    
    private func tagChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            DSHaptics.selection()
            withAnimation(DSAnimation.springQuick) {
                action()
            }
        } label: {
            Text(label)
                .font(DSFont.captionSmall())
                .foregroundStyle(isSelected ? .white : DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(
                    Capsule().fill(isSelected ? DSColor.accent : DSColor.surfaceLight)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            switch viewMode {
            case .list:
                LazyVStack(spacing: DSSpacing.xs) {
                    ForEach(filteredNotes) { note in
                        noteListRow(note)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, 120)
                
            case .grid:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
                    ForEach(filteredNotes) { note in
                        noteGridCard(note)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }
    
    private func noteListRow(_ note: NoteItem) -> some View {
        Button {
            editingNote = note
            showEditor = true
        } label: {
            HStack(spacing: DSSpacing.sm) {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    HStack(spacing: DSSpacing.xxs) {
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(DSColor.warning)
                        }
                        
                        Text(note.title)
                            .font(DSFont.headline())
                            .foregroundStyle(DSColor.textPrimary)
                            .lineLimit(1)
                    }
                    
                    if !note.content.isEmpty {
                        Text(note.preview)
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: DSSpacing.xs) {
                        Text(note.updatedAt, format: .dateTime.month(.abbreviated).day())
                            .font(.system(size: 10))
                            .foregroundStyle(DSColor.textTertiary)
                        
                        ForEach(note.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9))
                                .foregroundStyle(DSColor.accent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule().fill(DSColor.accent.opacity(0.1))
                                )
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(DSColor.textTertiary)
            }
            .glassCard(padding: DSSpacing.sm)
        }
        .buttonStyle(.plain)
    }
    
    private func noteGridCard(_ note: NoteItem) -> some View {
        Button {
            editingNote = note
            showEditor = true
        } label: {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(DSColor.warning)
                    }
                    Spacer()
                    Text(note.updatedAt, format: .dateTime.month(.abbreviated).day())
                        .font(.system(size: 9))
                        .foregroundStyle(DSColor.textTertiary)
                }
                
                Text(note.title)
                    .font(DSFont.headline())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !note.content.isEmpty {
                    Text(note.preview)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9))
                                .foregroundStyle(DSColor.accent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule().fill(DSColor.accent.opacity(0.1))
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 130)
            .glassCard(padding: DSSpacing.sm)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()
            
            Image(systemName: "note.text")
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textTertiary)
            
            Text("No notes yet")
                .font(DSFont.headline())
                .foregroundStyle(DSColor.textSecondary)
            
            Text("Capture your thoughts, ideas, and knowledge.")
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textTertiary)
                .multilineTextAlignment(.center)
            
            Button {
                editingNote = nil
                showEditor = true
            } label: {
                Text("Create Note")
                    .font(DSFont.caption())
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.vertical, DSSpacing.sm)
                    .background(Capsule().fill(DSColor.accent))
            }
            
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xxl)
    }
}

#Preview {
    NotesView()
}
