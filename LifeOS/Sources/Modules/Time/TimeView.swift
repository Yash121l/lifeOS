import SwiftUI
import SwiftData

struct TimeView: View {
    @Query(sort: \TimeBlock.startTime) private var blocks: [TimeBlock]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                if blocks.isEmpty {
                    Text("No events scheduled. Add a time block!")
                        .foregroundColor(.gray)
                }
                ForEach(blocks) { block in
                    VStack(alignment: .leading) {
                        Text(block.title)
                            .font(.headline)
                        Text("\(block.startTime, style: .time) - \(block.endTime, style: .time)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addMockBlock) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addMockBlock() {
        let newBlock = TimeBlock(title: "Deep Work", startTime: Date(), endTime: Date().addingTimeInterval(3600))
        modelContext.insert(newBlock)
    }
}

#Preview {
    TimeView()
}
