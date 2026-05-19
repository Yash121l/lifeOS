import SwiftUI

struct NotificationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    let payload: NotificationPayload
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xl) {
                    // Hero Header
                    heroSection
                    
                    // Info Cards
                    detailCards
                    
                    // Action Buttons
                    actionButtons
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle(payload.isTask ? "Task Details" : "Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: DSSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(heroColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(heroColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 72, height: 72)
                Image(systemName: heroIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(heroColor)
            }
            .glowShadow(heroColor)
            
            // Title
            Text(payload.title)
                .font(DSFont.title())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle / Time
            if let subtitle = payload.subtitle {
                Text(subtitle)
                    .font(DSFont.subheadline())
                    .foregroundStyle(DSColor.textSecondary)
            }
            
            // Category badge
            if let badge = payload.badge {
                Text(badge)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(heroColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(heroColor.opacity(0.12))
                            .overlay(Capsule().stroke(heroColor.opacity(0.2), lineWidth: 1))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }
    
    // MARK: - Detail Cards
    
    private var detailCards: some View {
        VStack(spacing: DSSpacing.sm) {
            // Time card
            if let startTime = payload.startTime {
                detailRow(icon: "clock.fill", label: "Time", value: {
                    if let endTime = payload.endTime {
                        return "\(formatDateTime(startTime)) – \(formatTime(endTime))"
                    }
                    return formatDateTime(startTime)
                }(), tint: DSColor.cyan)
            }
            
            // Due date for tasks
            if payload.isTask, let dueDate = payload.startTime {
                detailRow(icon: "calendar.badge.exclamationmark", label: "Due Date", value: formatDateTime(dueDate), tint: dueDate < Date() ? DSColor.error : DSColor.warning)
            }
            
            // Priority for tasks
            if let priority = payload.priority {
                let (priorityLabel, priorityColor) = priorityInfo(priority)
                detailRow(icon: "flag.fill", label: "Priority", value: priorityLabel, tint: priorityColor)
            }
            
            // Energy level for tasks
            if let energy = payload.energyLevel {
                let (energyLabel, energyColor) = energyInfo(energy)
                detailRow(icon: "bolt.fill", label: "Energy", value: energyLabel, tint: energyColor)
            }
            
            // Time estimate for tasks
            if let estimate = payload.timeEstimate, estimate > 0 {
                detailRow(icon: "timer", label: "Estimate", value: formatMinutes(estimate), tint: DSColor.accentLight)
            }
            
            // Location
            if let location = payload.location, !location.isEmpty {
                detailRow(icon: "location.fill", label: "Location", value: location, tint: DSColor.mint)
            }
            
            // Description / Notes
            if let description = payload.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 13))
                            .foregroundStyle(DSColor.textTertiary)
                        Text(payload.isTask ? "Notes" : "Description")
                            .font(DSFont.caption())
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    
                    Text(description.strippingHTMLAndFormatting())
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .glassCard(tint: DSColor.accentLight)
            }
            
            // Attendees
            if let attendees = payload.attendees, !attendees.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(DSColor.textTertiary)
                        Text("Participants")
                            .font(DSFont.caption())
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        ForEach(attendees) { attendee in
                            HStack(spacing: DSSpacing.sm) {
                                // Avatar circle
                                ZStack {
                                    Circle()
                                        .fill(DSColor.surfaceElevated)
                                        .frame(width: 32, height: 32)
                                    Text(String((attendee.displayName ?? attendee.email ?? "?").prefix(1)).uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(DSColor.textSecondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(attendee.displayName ?? attendee.email ?? "Unknown")
                                        .font(DSFont.caption())
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    
                                    if attendee.displayName != nil, let email = attendee.email {
                                        Text(email)
                                            .font(.system(size: 11))
                                            .foregroundStyle(DSColor.textTertiary)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                // Response Status Icon
                                if let status = attendee.responseStatus {
                                    switch status.lowercased() {
                                    case "accepted":
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(DSColor.success)
                                            .font(.system(size: 14))
                                    case "declined":
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(DSColor.error)
                                            .font(.system(size: 14))
                                    case "tentative":
                                        Image(systemName: "questionmark.circle.fill")
                                            .foregroundStyle(DSColor.warning)
                                            .font(.system(size: 14))
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, DSSpacing.xxs)
                }
                .glassCard(tint: DSColor.cyan)
            }
        }
    }
    
    private func detailRow(icon: String, label: String, value: String, tint: Color) -> some View {
        HStack(spacing: DSSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(tint)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                Text(value)
                    .font(DSFont.body())
                    .foregroundStyle(.white)
            }
            
            Spacer()
        }
        .glassCard(padding: DSSpacing.sm)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: DSSpacing.sm) {
            // Join Meeting
            if let meetingLink = payload.meetingLink, let url = URL(string: meetingLink) {
                Button {
                    DSHaptics.medium()
                    openURL(url)
                } label: {
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Join Meeting")
                            .font(DSFont.headline())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(DSGradient.accent)
                    )
                    .glowShadow(DSColor.accent)
                }
            }
            
            // Open in Calendar (for events with htmlLink)
            if let htmlLink = payload.htmlLink, let url = URL(string: htmlLink) {
                Button {
                    DSHaptics.light()
                    openURL(url)
                } label: {
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14, weight: .medium))
                        Text("Open in Google Calendar")
                            .font(DSFont.body())
                    }
                    .foregroundStyle(DSColor.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(DSColor.accent.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.lg)
                                    .stroke(DSColor.accent.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var heroColor: Color {
        if payload.meetingLink != nil { return DSColor.warning }
        if payload.isTask { return DSColor.accent }
        return DSColor.cyan
    }
    
    private var heroIcon: String {
        if payload.meetingLink != nil { return "video.fill" }
        if payload.isTask { return "checkmark.circle.fill" }
        return "calendar"
    }
    
    private func priorityInfo(_ priority: Int) -> (String, Color) {
        switch priority {
        case 0: return ("Low", DSColor.success)
        case 2: return ("High", DSColor.error)
        default: return ("Medium", DSColor.warning)
        }
    }
    
    private func energyInfo(_ energy: Int) -> (String, Color) {
        switch energy {
        case 1: return ("Low Energy", DSColor.energyLow)
        case 3: return ("High Energy", DSColor.energyHigh)
        default: return ("Medium Energy", DSColor.energyMedium)
        }
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes) min" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Notification Payload

struct NotificationPayload: Identifiable {
    let id = UUID()
    let isTask: Bool
    let title: String
    let subtitle: String?
    let badge: String?
    let description: String?
    let startTime: Date?
    let endTime: Date?
    let priority: Int?
    let energyLevel: Int?
    let timeEstimate: Int?
    let location: String?
    let meetingLink: String?
    let htmlLink: String?
    let taskId: String?
    let eventId: String?
    let attendees: [GoogleCalendarService.GoogleAttendee]?
    
    // Build from notification userInfo
    static func from(userInfo: [AnyHashable: Any]) -> NotificationPayload? {
        let type = userInfo[NotificationManager.notificationTypeKey] as? String ?? ""
        
        if type == "task" {
            let taskId = userInfo[NotificationManager.taskIdKey] as? String
            // Look up task from FirestoreService
            let task = FirestoreService.shared.tasks.first { $0.id == taskId }
            return NotificationPayload(
                isTask: true,
                title: task?.title ?? "Task",
                subtitle: task?.dueDate != nil ? "Due: \(DateFormatter.localizedString(from: task!.dueDate!, dateStyle: .medium, timeStyle: .short))" : nil,
                badge: task?.priorityLabel,
                description: task?.notes,
                startTime: task?.dueDate,
                endTime: nil,
                priority: task?.priority,
                energyLevel: task?.energyLevel,
                timeEstimate: task?.timeEstimateMinutes,
                location: nil,
                meetingLink: nil,
                htmlLink: nil,
                taskId: taskId,
                eventId: nil,
                attendees: nil
            )
        } else if type == "event" {
            let eventTitle = userInfo[NotificationManager.eventTitleKey] as? String ?? "Event"
            let startInterval = userInfo[NotificationManager.eventStartKey] as? TimeInterval
            let endInterval = userInfo[NotificationManager.eventEndKey] as? TimeInterval
            let desc = userInfo[NotificationManager.eventDescriptionKey] as? String
            let location = userInfo[NotificationManager.eventLocationKey] as? String
            let meetingLink = userInfo[NotificationManager.eventMeetingLinkKey] as? String
            let isAllDay = userInfo[NotificationManager.eventIsAllDayKey] as? Bool ?? false
            
            let startDate = startInterval.map { Date(timeIntervalSince1970: $0) }
            let endDate = endInterval.map { Date(timeIntervalSince1970: $0) }
            
            return NotificationPayload(
                isTask: false,
                title: eventTitle,
                subtitle: isAllDay ? "All Day" : nil,
                badge: meetingLink != nil ? "📹 Meeting" : "📅 Event",
                description: desc,
                startTime: startDate,
                endTime: endDate,
                priority: nil,
                energyLevel: nil,
                timeEstimate: nil,
                location: location,
                meetingLink: meetingLink,
                htmlLink: nil,
                taskId: nil,
                eventId: userInfo[NotificationManager.eventIdKey] as? String,
                attendees: nil // Can't easily pass full attendee array through APNs payload; relying on fetch if needed
            )
        }
        
        return nil
    }
    
    // Build from GoogleCalendarEvent directly
    static func fromEvent(_ event: GoogleCalendarService.GoogleCalendarEvent) -> NotificationPayload {
        NotificationPayload(
            isTask: false,
            title: event.title,
            subtitle: event.isAllDay ? "All Day" : nil,
            badge: event.hangoutLink != nil ? "📹 Meeting" : "📅 Event",
            description: event.description,
            startTime: event.startDate,
            endTime: event.endDate,
            priority: nil,
            energyLevel: nil,
            timeEstimate: nil,
            location: event.location,
            meetingLink: event.hangoutLink,
            htmlLink: event.htmlLink,
            taskId: nil,
            eventId: event.id,
            attendees: event.attendees
        )
    }
    
    // Build from TaskItem directly
    static func fromTask(_ task: TaskItem) -> NotificationPayload {
        NotificationPayload(
            isTask: true,
            title: task.title,
            subtitle: task.dueDate.map { "Due: \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short))" },
            badge: task.priorityLabel,
            description: task.notes.isEmpty ? nil : task.notes,
            startTime: task.dueDate,
            endTime: nil,
            priority: task.priority,
            energyLevel: task.energyLevel,
            timeEstimate: task.timeEstimateMinutes,
            location: nil,
            meetingLink: nil,
            htmlLink: nil,
            taskId: task.id,
            eventId: nil,
            attendees: nil
        )
    }
}
