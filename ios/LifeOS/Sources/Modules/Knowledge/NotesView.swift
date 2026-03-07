import SwiftUI

struct NotesView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var searchText = ""
    @State private var showGrid = true
    @State private var showEditor = false
    @State private var selectedNote: NoteItem?
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var pinnedNotes: [NoteItem] {
        store.notes.filter { $0.isPinned && matchesSearch($0) }
    }
    
    private var otherNotes: [NoteItem] {
        store.notes.filter { !$0.isPinned && matchesSearch($0) }
    }
    
    private func matchesSearch(_ note: NoteItem) -> Bool {
        if searchText.isEmpty { return true }
        return note.title.localizedCaseInsensitiveContains(searchText) ||
               note.content.localizedCaseInsensitiveContains(searchText) ||
               note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Search + view toggle
                    HStack(spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: DSIcon.search)
                                .foregroundStyle(DSColor.textTertiary)
                            TextField("Search notes...", text: $searchText)
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                        }
                        .padding(DSSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .fill(DSColor.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(DSColor.cardBorder, lineWidth: 1)
                                )
                        )
                        
                        Button {
                            DSHaptics.selection()
                            withAnimation(DSAnimation.springQuick) { showGrid.toggle() }
                        } label: {
                            Image(systemName: showGrid ? "list.bullet" : "square.grid.2x2")
                                .font(.system(size: 18))
                                .foregroundStyle(DSColor.textSecondary)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.sm)
                                        .fill(DSColor.surfaceElevated)
                                )
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, DSSpacing.sm)
                    
                    if store.notes.isEmpty && searchText.isEmpty {
                        VStack {
                            DSEmptyState(
                                icon: "note.text",
                                title: "No notes yet",
                                subtitle: "Capture your thoughts and ideas",
                                actionTitle: "New Note"
                            ) {
                                showEditor = true
                            }
                            .glassCard()
                            Spacer()
                        }
                        .padding(.horizontal, DSSpacing.md)
                    } else if showGrid {
                        // Grid view with context menus
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: DSSpacing.lg) {
                                if !pinnedNotes.isEmpty {
                                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                                        DSSectionHeader("Pinned", count: pinnedNotes.count)
                                        notesGrid(pinnedNotes)
                                    }
                                }
                                
                                if !otherNotes.isEmpty {
                                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                                        DSSectionHeader("Notes", count: otherNotes.count)
                                        notesGrid(otherNotes)
                                    }
                                }
                                
                                Spacer(minLength: 100)
                            }
                            .padding(.horizontal, DSSpacing.md)
                        }
                    } else {
                        // List view with swipe actions
                        List {
                            if !pinnedNotes.isEmpty {
                                Section {
                                    ForEach(pinnedNotes) { note in
                                        noteListRow(note)
                                            .onTapGesture {
                                                DSHaptics.selection()
                                                selectedNote = note
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    DSHaptics.error()
                                                    Task { try? await store.deleteNote(note.id, userId: userId) }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                                Button {
                                                    DSHaptics.selection()
                                                    var updated = note
                                                    updated.isPinned = false
                                                    Task { try? await store.saveNote(updated, userId: userId) }
                                                } label: {
                                                    Label("Unpin", systemImage: "pin.slash")
                                                }
                                                .tint(DSColor.amber)
                                            }
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    }
                                } header: {
                                    DSSectionHeader("Pinned", count: pinnedNotes.count)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                }
                            }
                            
                            if !otherNotes.isEmpty {
                                Section {
                                    ForEach(otherNotes) { note in
                                        noteListRow(note)
                                            .onTapGesture {
                                                DSHaptics.selection()
                                                selectedNote = note
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    DSHaptics.error()
                                                    Task { try? await store.deleteNote(note.id, userId: userId) }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                                Button {
                                                    DSHaptics.selection()
                                                    var updated = note
                                                    updated.isPinned = true
                                                    Task { try? await store.saveNote(updated, userId: userId) }
                                                } label: {
                                                    Label("Pin", systemImage: "pin")
                                                }
                                                .tint(DSColor.amber)
                                            }
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    }
                                } header: {
                                    DSSectionHeader("Notes", count: otherNotes.count)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSGradient.accent))
                        .shadow(color: DSColor.accent.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.trailing, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }
            .navigationTitle("Notes")
            .sheet(isPresented: $showEditor) {
                NoteEditorView(note: nil)
            }
            .sheet(item: $selectedNote) { note in
                NoteEditorView(note: note)
            }
        }
    }
    
    // MARK: - Grid Layout
    
    private func notesGrid(_ notes: [NoteItem]) -> some View {
        let columns = [GridItem(.flexible(), spacing: DSSpacing.xs), GridItem(.flexible(), spacing: DSSpacing.xs)]
        
        return LazyVGrid(columns: columns, spacing: DSSpacing.xs) {
            ForEach(notes) { note in
                noteGridCard(note)
                    .onTapGesture {
                        DSHaptics.selection()
                        selectedNote = note
                    }
                    .contextMenu {
                        Button {
                            DSHaptics.selection()
                            var updated = note
                            updated.isPinned.toggle()
                            Task { try? await store.saveNote(updated, userId: userId) }
                        } label: {
                            Label(
                                note.isPinned ? "Unpin" : "Pin",
                                systemImage: note.isPinned ? "pin.slash.fill" : "pin.fill"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            DSHaptics.error()
                            Task { try? await store.deleteNote(note.id, userId: userId) }
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
            }
        }
    }
    
    private func noteGridCard(_ note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(DSFont.headline())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Spacer()
                
                if note.isPinned {
                    Image(systemName: DSIcon.pinned)
                        .font(.system(size: 10))
                        .foregroundStyle(DSColor.amber)
                }
            }
            
            Text(note.preview.isEmpty ? "No content" : note.preview)
                .font(DSFont.captionSmall())
                .foregroundStyle(DSColor.textTertiary)
                .lineLimit(4)
            
            Spacer(minLength: 0)
            
            if !note.tags.isEmpty {
                HStack(spacing: DSSpacing.xxs) {
                    ForEach(note.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(DSColor.accent)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(DSColor.accent.opacity(0.1)))
                    }
                }
            }
            
            Text(note.updatedAt, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 9))
                .foregroundStyle(DSColor.textTertiary)
        }
        .frame(minHeight: 120)
        .glassCard(padding: DSSpacing.sm)
    }
    
    // MARK: - List Row
    
    private func noteListRow(_ note: NoteItem) -> some View {
        HStack(spacing: DSSpacing.sm) {
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                HStack(spacing: DSSpacing.xs) {
                    if note.isPinned {
                        Image(systemName: DSIcon.pinned)
                            .font(.system(size: 10))
                            .foregroundStyle(DSColor.amber)
                    }
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(DSFont.body())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                
                Text(note.preview.isEmpty ? "No content" : note.preview)
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    Text(note.updatedAt, format: .dateTime.month(.abbreviated).day())
                        .font(.system(size: 9))
                        .foregroundStyle(DSColor.textTertiary)
                    
                    ForEach(note.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(DSColor.accent)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DSColor.textTertiary)
        }
        .glassCard(padding: DSSpacing.sm)
    }
}
