import SwiftUI
import SwiftData

struct TimeView: View {
    @Query(sort: \TimeBlock.startTime) private var blocks: [TimeBlock]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    
    // Generate dates for horizontal picker
    private var daysOfWeek: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        for i in -3...10 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private var selectedDayBlocks: [TimeBlock] {
        blocks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Horizontal Day Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 15) {
                            ForEach(daysOfWeek, id: \.self) { date in
                                DayPickerCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                                    .onTapGesture {
                                        withAnimation {
                                            selectedDate = date
                                        }
                                    }
                                    .id(date)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .onAppear {
                            proxy.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                
                // Blocks List
                List {
                    if selectedDayBlocks.isEmpty {
                        Text("No events scheduled for this day.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    }
                    ForEach(selectedDayBlocks) { block in
                        HStack(spacing: 12) {
                            // Timeline logic (simplified for now)
                            VStack {
                                Text(block.startTime, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .frame(width: 50, alignment: .trailing)
                            
                            // Event block
                            VStack(alignment: .leading, spacing: 4) {
                                Text(block.title)
                                    .font(.headline)
                                Text("\(block.startTime, style: .time) - \(block.endTime, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
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
        let newBlock = TimeBlock(title: "Deep Work", startTime: selectedDate, endTime: selectedDate.addingTimeInterval(3600))
        modelContext.insert(newBlock)
    }
}

// Subview for DayPicker
struct DayPickerCell: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.accentColor : Color.clear)
                .clipShape(Circle())
        }
    }
}

#Preview {
    TimeView()
}
