import SwiftUI
import SwiftData

struct TimeView: View {
    @Query(sort: \TimeBlock.startTime) private var blocks: [TimeBlock]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var showAddBlock = false
    
    // Generate dates for horizontal picker
    private var daysOfWeek: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (-3...14).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    private var selectedDayBlocks: [TimeBlock] {
        blocks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    // Hour grid markers (6 AM to midnight)
    private let hourMarkers = Array(6...23)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Day Picker
                dayPicker
                
                // MARK: - Time Grid
                timeGrid
            }
            .background(DSColor.background)
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            withAnimation(DSAnimation.springQuick) {
                                selectedDate = Date()
                            }
                        } label: {
                            Text("Today")
                                .font(DSFont.caption())
                                .foregroundStyle(isToday ? DSColor.textTertiary : DSColor.accent)
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(isToday ? DSColor.surfaceLight : DSColor.accent.opacity(0.15))
                                )
                        }
                        .disabled(isToday)
                        
                        Button {
                            showAddBlock = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(DSColor.accent)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Day Picker
    
    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: DSSpacing.sm) {
                    ForEach(daysOfWeek, id: \.self) { date in
                        DayPickerCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                        .onTapGesture {
                            DSHaptics.selection()
                            withAnimation(DSAnimation.springQuick) {
                                selectedDate = date
                            }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .onAppear {
                    proxy.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Time Grid
    
    private var timeGrid: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                // Hour grid lines
                VStack(spacing: 0) {
                    ForEach(hourMarkers, id: \.self) { hour in
                        HStack(alignment: .top, spacing: DSSpacing.sm) {
                            Text(hourLabel(hour))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(DSColor.textTertiary)
                                .frame(width: 40, alignment: .trailing)
                            
                            VStack {
                                Divider()
                                    .overlay(DSColor.cardBorder)
                                Spacer()
                            }
                        }
                        .frame(height: 60)
                    }
                }
                
                // Time blocks positioned on grid
                ForEach(selectedDayBlocks) { block in
                    timeBlockCard(block)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.bottom, 120)
        }
    }
    
    private func timeBlockCard(_ block: TimeBlock) -> some View {
        let calendar = Calendar.current
        let blockHour = calendar.component(.hour, from: block.startTime)
        let blockMinute = calendar.component(.minute, from: block.startTime)
        
        let startOffset = max(0, CGFloat(blockHour - 6) * 60 + CGFloat(blockMinute))
        let duration = CGFloat(block.durationMinutes)
        let blockColor = Color(hex: block.colorHex)
        
        return VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(block.title)
                .font(DSFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Text("\(block.startTime, style: .time) – \(block.endTime, style: .time)")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(DSSpacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: max(30, duration))
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(blockColor.opacity(0.85))
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.4))
                .frame(width: 3)
                .padding(.vertical, 4)
                .padding(.leading, 3)
        }
        .padding(.leading, 56) // After the time labels
        .padding(.trailing, DSSpacing.xs)
        .offset(y: startOffset)
    }
    
    private func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h) \(ampm)"
    }
    
    private func addMockBlock() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let start = calendar.date(bySettingHour: hour + 1, minute: 0, second: 0, of: selectedDate) ?? selectedDate
        let end = start.addingTimeInterval(3600)
        let block = TimeBlock(title: "Deep Work", startTime: start, endTime: end, colorHex: "5E5CE6", blockType: "deepWork")
        modelContext.insert(block)
    }
}

// MARK: - Day Picker Cell

struct DayPickerCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? .white : DSColor.textTertiary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isSelected ? .white : DSColor.textPrimary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? DSColor.accent : Color.clear)
                )
            
            // Today indicator dot
            Circle()
                .fill(isToday && !isSelected ? DSColor.accent : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(width: 44)
    }
}

#Preview {
    TimeView()
}
