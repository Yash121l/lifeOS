import SwiftUI

struct FocusAnalyticsView: View {
    @State private var store = FirestoreService.shared
    @State private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - Computed

    private var allSessions: [FocusSession] {
        store.focusSessions.sorted { $0.startedAt > $1.startedAt }
    }

    private var todaySessions: [FocusSession] {
        allSessions.filter { Calendar.current.isDateInToday($0.startedAt) }
    }

    private var weekSessions: [FocusSession] {
        let start = Calendar.current.startOfWeek(for: Date())
        return allSessions.filter { $0.startedAt >= start }
    }

    private var todayMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.durationSeconds / 60 }
    }

    private var weekMinutes: Int {
        weekSessions.reduce(0) { $0 + $1.durationSeconds / 60 }
    }

    private var completionRate: Double {
        guard !allSessions.isEmpty else { return 0 }
        let completed = allSessions.filter { $0.isCompleted }.count
        return Double(completed) / Double(allSessions.count)
    }

    private var streak: Int {
        var count = 0
        var date = Calendar.current.startOfDay(for: Date())
        while true {
            let has = allSessions.contains { Calendar.current.isDate($0.startedAt, inSameDayAs: date) }
            if has { count += 1 } else { break }
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return count
    }

    /// 7 bars: Mon–Sun minutes
    private var weekBars: [(label: String, minutes: Int)] {
        let cal = Calendar.current
        let today = Date()
        let startOfWeek = cal.startOfWeek(for: today)

        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: startOfWeek)!
            let label = day.formatted(.dateTime.weekday(.abbreviated))
            let mins = allSessions
                .filter { cal.isDate($0.startedAt, inSameDayAs: day) }
                .reduce(0) { $0 + $1.durationSeconds / 60 }
            return (label, mins)
        }
    }

    private var maxBar: Int { weekBars.map(\.minutes).max() ?? 1 }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // Hero stats
                    statsRow

                    // Week bar chart
                    weekChart

                    // Streak + completion
                    metricsRow

                    // Recent sessions list
                    if !allSessions.isEmpty {
                        recentSessions
                    } else {
                        emptyState
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
            }
            .background(DSColor.background)
            .navigationTitle("Focus Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(DSColor.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "clock.fill",
                value: formatMins(todayMinutes),
                label: "Today",
                color: DSColor.accent
            )
            statCard(
                icon: "calendar.badge.clock",
                value: formatMins(weekMinutes),
                label: "This week",
                color: Color(hex: "5BAEFF")
            )
            statCard(
                icon: "checkmark.seal.fill",
                value: "\(Int(completionRate * 100))%",
                label: "Completed",
                color: DSColor.success
            )
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DSColor.hairline, lineWidth: 0.5))
    }

    // MARK: - Week Bar Chart

    private var weekChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("THIS WEEK")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
                .kerning(0.6)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(weekBars, id: \.label) { bar in
                    let isToday = bar.label == Date().formatted(.dateTime.weekday(.abbreviated))
                    VStack(spacing: 6) {
                        // Bar
                        let height = maxBar > 0
                            ? max(4, CGFloat(bar.minutes) / CGFloat(maxBar) * 80)
                            : 4

                        RoundedRectangle(cornerRadius: 5)
                            .fill(isToday ? DSColor.accent : DSColor.accent.opacity(0.35))
                            .frame(height: height)

                        Text(bar.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(isToday ? DSColor.accent : DSColor.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.4), value: bar.minutes)
                }
            }
            .frame(height: 106) // bar 80 + label + spacing

            // X labels for minutes at top bar
            if maxBar > 0 {
                Text("Peak: \(formatMins(maxBar))")
                    .font(.system(size: 11))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .padding(18)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DSColor.hairline, lineWidth: 0.5))
    }

    // MARK: - Metrics Row

    private var metricsRow: some View {
        HStack(spacing: 12) {
            // Streak
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color(hex: "FF6A4A"))
                    Text("Streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DSColor.textSecondary)
                }
                Text("\(streak) day\(streak == 1 ? "" : "s")")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DSColor.hairline, lineWidth: 0.5))

            // Sessions
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(DSColor.warning)
                    Text("Sessions")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DSColor.textSecondary)
                }
                Text("\(allSessions.count)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DSColor.hairline, lineWidth: 0.5))
        }
    }

    // MARK: - Recent Sessions

    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader("Recent sessions", count: min(allSessions.count, 10))

            VStack(spacing: 0) {
                ForEach(Array(allSessions.prefix(10))) { session in
                    sessionRow(session)
                    if session.id != allSessions.prefix(10).last?.id {
                        Divider()
                            .background(DSColor.hairline)
                            .padding(.leading, 52)
                    }
                }
            }
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DSColor.hairline, lineWidth: 0.5))
            .padding(.horizontal, -18) // counteract parent padding
            .padding(.horizontal, 0)
        }
        .padding(.horizontal, 0) // Let the list cards be full width
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "clock.badge.xmark")
                .font(.system(size: 18))
                .foregroundStyle(session.isCompleted ? DSColor.success : DSColor.warning)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(
                        (session.isCompleted ? DSColor.success : DSColor.warning).opacity(0.12)
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(session.taskTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(session.startedAt.formatted(.dateTime.day().month().hour().minute()))
                    .font(.system(size: 12))
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatMins(session.durationSeconds / 60))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Text("/ \(formatMins(session.goalSeconds / 60))")
                    .font(.system(size: 11))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.system(size: 44))
                .foregroundStyle(DSColor.accent.opacity(0.4))

            Text("No sessions yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Text("Start a focus session from the Dashboard to see your analytics here.")
                .font(.system(size: 14))
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func formatMins(_ minutes: Int) -> String {
        if minutes == 0 { return "0m" }
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

// MARK: - Calendar extension

private extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
