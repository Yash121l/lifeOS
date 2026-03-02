import SwiftUI
import SwiftData

struct NotesView: View {
    @Query(sort: \NoteItem.updatedAt, order: .reverse) private var notes: [NoteItem]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                if notes.isEmpty {
                    Text("No notes found. Capture your thoughts!")
                        .foregroundColor(.gray)
                }
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title).font(.headline)
                        Text(note.content).font(.subheadline).lineLimit(2).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Knowledge Base")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addMockNote) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addMockNote() {
        let note = NoteItem(title: "New Idea", content: "This is a great idea about SwiftUI architecture...")
        modelContext.insert(note)
    }
}

#Preview {
    NotesView()
}
