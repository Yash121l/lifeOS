import SwiftUI

struct TimeView: View {
    @EnvironmentObject var di: DIContainer
    @StateObject private var viewModel = TimeViewModel()
    
    @State private var showAddEvent = false
    @State private var selectedEventPayload: NotificationPayload?
    @State private var searchText = ""         // for event search
    @State private var showSearch = false
    
    private let startHour = 8
    private let endHour = 20
    private let hourHeight: CGFloat = 64
    

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        
                        searchBarSection
                        
                        dateStrip
                            .padding(.bottom, 20)
                        
                        // Timeline
                        ZStack(alignment: .topLeading) {
                            hourGrid
                            
                            allDayEventsBanner
                            
                            unifiedBlocksOverlay
                            
                            if Calendar.current.isDateInToday(viewModel.selectedDate) {
                                currentTimeIndicator
                            }
                        }
                        .padding(.horizontal, DSSpacing.md)
                        
                        Spacer(minLength: 120)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddEvent = true
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
            .sheet(isPresented: $showAddEvent) {
                EventEntryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DSColor.background)
            }
            .sheet(item: $selectedEventPayload) { payload in
                NotificationDetailView(payload: payload)
            }
            .onAppear {
                viewModel.setup(auth: di.auth, database: di.database)
                Task {
                    await viewModel.loadGoogleEvents()
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                Text(Calendar.current.isDateInToday(viewModel.selectedDate) ? "Today" : viewModel.selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-1.2)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    DSHaptics.selection()
                    withAnimation(.spring(response: 0.3)) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                } label: {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(showSearch ? DSColor.accent : DSColor.surface))
                        .animation(.spring(response: 0.2), value: showSearch)
                }
                
                Button {
                    DSHaptics.selection()
                    viewModel.selectedDate = Date()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(Calendar.current.isDateInToday(viewModel.selectedDate) ? DSColor.accent : .white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(DSColor.surface))
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.top, 60)
        .padding(.bottom, showSearch ? 4 : 8)
    }
    
    // MARK: - Search Bar (conditionally visible)
    
    @ViewBuilder
    private var searchBarSection: some View {
        if showSearch {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                TextField("Search events...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DSColor.hairline, lineWidth: 0.5))
            .padding(.horizontal, 22)
            .padding(.bottom, 10)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Date Strip
    
    private var dateStrip: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.datesThisWeek, id: \.self) { date in
                let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let hasEvents = viewModel.hasEvents(on: date)
                
                Button {
                    DSHaptics.selection()
                    withAnimation(DSAnimation.springQuick) { viewModel.changeDate(date) }
                } label: {
                    VStack(spacing: 4) {
                        Text(date, format: .dateTime.weekday(.abbreviated))
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : DSColor.textSecondary)
                            .textCase(.uppercase)
                        
                        Text(date, format: .dateTime.day())
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(isSelected ? .white : (isToday ? DSColor.accent : .white))
                        
                        Circle()
                            .fill(hasEvents ? (isSelected ? .white : DSColor.accent) : .clear)
                            .frame(width: 4, height: 4)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? DSColor.accent : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.horizontal, 14)
    }
    
    // MARK: - Hour Grid
    
    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    // Time label
                    Text(formatHour(hour))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary)
                        .kerning(0.4)
                        .frame(width: 44, alignment: .leading)
                        .offset(y: -7)
                    
                    // Horizontal line
                    VStack {
                        Rectangle()
                            .fill(DSColor.hairline)
                            .frame(height: 0.5)
                        Spacer()
                    }
                    .padding(.leading, 8)
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h) \(ampm)"
    }
    
    private func yPosition(for date: Date) -> CGFloat {
        let cal = Calendar.current
        let hour = CGFloat(cal.component(.hour, from: date))
        let minute = CGFloat(cal.component(.minute, from: date))
        return (hour - CGFloat(startHour)) * hourHeight + (minute / 60.0) * hourHeight
    }
    

    
    // MARK: - All Day Banner
    private var allDayEventsBanner: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56
            let blockWidth = geo.size.width - timelineLeading - DSSpacing.sm
            
            VStack(spacing: 2) {
                ForEach(viewModel.calendarEventsForSelectedDate.filter { $0.isAllDay }) { event in
                    HStack(spacing: 6) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
                        Text(event.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("All day")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 6)
                    .frame(width: blockWidth)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .fill(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.sm)
                                    .stroke(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.6), lineWidth: 1)
                            )
                    )
                    .offset(x: timelineLeading, y: 2)
                    .onTapGesture {
                        DSHaptics.light()
                        selectedEventPayload = NotificationPayload.fromEvent(event)
                    }
                }
            }
        }
    }
    
    // MARK: - Unified View Layout Layer
    
    private var unifiedBlocksOverlay: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56
            let fullWidth = geo.size.width - timelineLeading - 4
            
            ForEach(viewModel.layoutEvents) { event in
                let yOffset = yPosition(for: event.startTime)
                let height = yPosition(for: event.endTime) - yOffset
                
                let columnWidth = fullWidth / CGFloat(event.totalColumns)
                let xOffset = timelineLeading + (CGFloat(event.column) * columnWidth)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .kerning(-0.2)
                        .lineLimit(1)
                    
                    Text("\(event.startTime, format: .dateTime.hour().minute()) – \(event.endTime, format: .dateTime.hour().minute())")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: columnWidth - 4, height: height - 4, alignment: .topLeading)
                .background(
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(event.color.opacity(0.15))
                        
                        Rectangle()
                            .fill(event.color)
                            .frame(width: 3)
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(event.color.opacity(0.25), lineWidth: 0.5)
                )
                .offset(x: xOffset, y: yOffset)
                .onTapGesture {
                    DSHaptics.light()
                    // handle tap
                }
            }
        }
    }
    
    // MARK: - Current Time Indicator
    
    private var currentTimeIndicator: some View {
        let now = Date()
        let cal = Calendar.current
        let hour = CGFloat(cal.component(.hour, from: now))
        let minute = CGFloat(cal.component(.minute, from: now))
        let yOffset = (hour - CGFloat(startHour)) * hourHeight + (minute / 60.0) * hourHeight
        
        return HStack(spacing: 4) {
            Text(now, format: .dateTime.hour().minute())
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .foregroundStyle(DSColor.error)
                .frame(width: 48, alignment: .trailing)
            
            Circle()
                .fill(DSColor.error)
                .frame(width: 8, height: 8)
                .glowShadow(DSColor.error)
            
            Rectangle()
                .fill(DSColor.error)
                .frame(height: 1.5)
        }
        .offset(y: yOffset - 4)
        .opacity(hour >= CGFloat(startHour) && hour < CGFloat(endHour) ? 1 : 0)
    }
}
