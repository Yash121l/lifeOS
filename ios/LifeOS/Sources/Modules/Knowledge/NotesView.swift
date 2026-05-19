import SwiftUI

struct NotesView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    enum ViewMode { case grid, list }
    
    @State private var viewMode: ViewMode = .grid
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showEditor = false
    @State private var selectedNote: NoteItem?
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var allTags: [String] {
        Array(Set(store.notes.flatMap { $0.tags })).sorted()
    }
    
    private var filteredNotes: [NoteItem] {
        var result = store.notes
        
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    private var pinnedNotes: [NoteItem] { filteredNotes.filter { $0.isPinned } }
    private var otherNotes: [NoteItem] { filteredNotes.filter { !$0.isPinned } }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        
                        // Search
                        searchBar
                            .padding(.horizontal, 22)
                            .padding(.bottom, 14)
                        
                        // Tags
                        tagsFilterRow
                            .padding(.bottom, 18)
                        
                        // Pinned
                        if !pinnedNotes.isEmpty {
                            DSSectionHeader("Pinned", count: pinnedNotes.count)
                            notesDisplay(pinnedNotes)
                                .padding(.bottom, 22)
                        }
                        
                        // All notes
                        if !otherNotes.isEmpty {
                            DSSectionHeader(pinnedNotes.isEmpty ? "Notes" : "All notes", count: otherNotes.count)
                            notesDisplay(otherNotes)
                        }
                        
                        if filteredNotes.isEmpty {
                            DSEmptyState(
                                icon: "book",
                                title: searchText.isEmpty ? "No notes" : "No matches",
                                subtitle: searchText.isEmpty ? "Tap + to capture a thought." : "Try a different search."
                            )
                            .padding(.top, 40)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSColor.accent))
                        .shadow(color: DSColor.accent.opacity(0.35), radius: 12, y: 8)
                }
                .padding(.trailing, 18)
                .padding(.bottom, 30)
            }
            .toolbar(.hidden)
            .sheet(isPresented: $showEditor) {
                NoteEditorView(note: nil)
            }
            .sheet(item: $selectedNote) { note in
                NoteEditorView(note: note)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(store.notes.count) notes")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                Text("Notes")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-1.2)
            }
            
            Spacer()
            
            Button {
                DSHaptics.selection()
                withAnimation(.spring()) {
                    viewMode = viewMode == .grid ? .list : .grid
                }
            } label: {
                Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.surface))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.top, 60)
        .padding(.bottom, 22)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DSColor.textSecondary)
            
            TextField("Search notes", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .kerning(-0.2)
            
            Button { DSHaptics.light() } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(DSColor.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DSColor.hairline, lineWidth: 0.5)
        )
    }
    
    // MARK: - Tags Filter
    
    private var tagsFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tagChip(label: "All", isActive: selectedTag == nil) {
                    selectedTag = nil
                }
                
                ForEach(allTags, id: \.self) { tag in
                    tagChip(label: tag, isActive: selectedTag == tag) {
                        selectedTag = (selectedTag == tag) ? nil : tag
                    }
                }
            }
            .padding(.horizontal, 22)
        }
    }
    
    private func tagChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            DSHaptics.selection()
            action()
        }) {
            Text(label)
                .font(.system(size: 13.5, weight: .medium))
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(isActive ? .white : DSColor.surface.opacity(0.5))
                .foregroundStyle(isActive ? .black : .white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isActive ? .white : DSColor.hairline, lineWidth: 0.5)
                )
        }
    }
    
    // MARK: - Notes Display
    
    @ViewBuilder
    private func notesDisplay(_ notes: [NoteItem]) -> some View {
        if viewMode == .list {
            VStack(spacing: 0) {
                ForEach(notes.indices, id: \.self) { index in
                    noteRow(notes[index], isLast: index == notes.count - 1)
                }
            }
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(DSColor.hairline, lineWidth: 0.5)
            )
            .padding(.horizontal, 18)
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(notes) { note in
                    noteCard(note)
                }
            }
            .padding(.horizontal, 18)
        }
    }
    
    private func noteRow(_ note: NoteItem, isLast: Bool) -> some View {
        Button {
            selectedNote = note
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                    }
                    Text(note.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .kerning(-0.3)
                }
                
                Text(note.content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                    .font(.system(size: 13.5))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    ForEach(note.tags.prefix(2), id: \.self) { tag in
                        DSPill(text: "#\(tag)")
                    }
                    Spacer()
                    Text(note.updatedAt.formatted(.dateTime.day().month()))
                        .font(.system(size: 12))
                        .foregroundStyle(DSColor.textTertiary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Divider()
                        .background(DSColor.hairline)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                DSHaptics.medium()
                Task { try? await store.deleteNote(note.id, userId: userId) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func noteCard(_ note: NoteItem) -> some View {
        Button {
            selectedNote = note
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                    }
                    Text(note.title)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(.white)
                        .kerning(-0.2)
                        .lineLimit(1)
                }
                
                Text(note.content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                    .font(.system(size: 12.5))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 8)
                
                HStack(spacing: 4) {
                    if let firstTag = note.tags.first {
                        DSPill(text: "#\(firstTag)")
                    }
                    Spacer()
                    Text(note.updatedAt.formatted(.dateTime.day().month()))
                        .font(.system(size: 11))
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 144, alignment: .topLeading)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DSColor.hairline, lineWidth: 0.5)
            )
        }
    }
}
