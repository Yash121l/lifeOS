import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var settings = SettingsManager.shared
    @State private var calService = GoogleCalendarService.shared
    @State private var showSignOutAlert = false
    @State private var syncMessage: String?
    @State private var isConnecting = false
    @State private var notifManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.xl) {
                    profileCard
                    preferencesSection
                    notificationsSection
                    googleCalendarSection
                    accountSection
                    
                    Text("LifeOS v1.0.0")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                        .padding(.top, DSSpacing.lg)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(DSFont.headline())
                        .foregroundStyle(DSColor.accent)
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out? Your data will sync when you sign back in.")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        HStack(spacing: DSSpacing.md) {
            DSAvatar(initials: authService.initials, size: 56)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(authService.displayName)
                    .font(DSFont.title())
                    .foregroundStyle(.white)
                
                Text(authService.email)
                    .font(DSFont.caption())
                    .foregroundStyle(DSColor.textSecondary)
            }
            
            Spacer()
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.xl)
                .fill(DSColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .fill(DSColor.accent.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .stroke(DSColor.cardBorder, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Preferences
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionLabel("PREFERENCES")
            
            VStack(spacing: 0) {
                settingsRow(icon: "indianrupeesign.circle", iconColor: DSColor.amber) {
                    HStack {
                        Text("Currency")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Currency", selection: $settings.currencyCode) {
                            ForEach(settings.availableCurrencies, id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                        .tint(DSColor.accent)
                        .labelsHidden()
                    }
                }
                
                settingsDivider
                
                settingsRow(icon: "globe", iconColor: DSColor.cyan) {
                    HStack {
                        Text("Timezone")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Timezone", selection: $settings.timezone) {
                            ForEach(settings.availableTimezones, id: \.self) { tz in
                                Text(tz.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? tz).tag(tz)
                            }
                        }
                        .tint(DSColor.accent)
                        .labelsHidden()
                    }
                }
            }
            .glassCard(padding: 0)
        }
    }
    
    // MARK: - Notifications
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionLabel("NOTIFICATIONS")
            
            VStack(spacing: 0) {
                settingsRow(icon: "checkmark.circle.fill", iconColor: DSColor.accent) {
                    HStack {
                        Text("Task Reminders")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Toggle("", isOn: $notifManager.taskRemindersEnabled)
                            .labelsHidden()
                            .tint(DSColor.success)
                            .onChange(of: notifManager.taskRemindersEnabled) { _, _ in
                                notifManager.saveSettings()
                            }
                    }
                }
                
                settingsDivider
                
                settingsRow(icon: "calendar.badge.clock", iconColor: DSColor.cyan) {
                    HStack {
                        Text("Event Reminders")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Toggle("", isOn: $notifManager.eventRemindersEnabled)
                            .labelsHidden()
                            .tint(DSColor.success)
                            .onChange(of: notifManager.eventRemindersEnabled) { _, _ in
                                notifManager.saveSettings()
                            }
                    }
                }
                
                settingsDivider
                
                settingsRow(icon: "clock.fill", iconColor: DSColor.amber) {
                    HStack {
                        Text("Remind Before")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Minutes", selection: $notifManager.reminderMinutesBefore) {
                            Text("5 min").tag(5)
                            Text("10 min").tag(10)
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("1 hour").tag(60)
                        }
                        .tint(DSColor.accent)
                        .labelsHidden()
                        .onChange(of: notifManager.reminderMinutesBefore) { _, _ in
                            notifManager.saveSettings()
                        }
                    }
                }
                
                settingsDivider
                
                Button {
                    notifManager.openSystemSettings()
                } label: {
                    settingsRow(icon: "gear", iconColor: DSColor.textSecondary) {
                        HStack {
                            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                                Text("System Settings")
                                    .font(DSFont.body())
                                    .foregroundStyle(.white)
                                Text(notifManager.isAuthorized ? "Notifications enabled" : "Tap to enable notifications")
                                    .font(DSFont.captionSmall())
                                    .foregroundStyle(notifManager.isAuthorized ? DSColor.success : DSColor.error)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(DSColor.textTertiary)
                        }
                    }
                }
                
                if notifManager.isAuthorized {
                    settingsDivider
                    
                    Button {
                        DSHaptics.light()
                        notifManager.sendTestNotification()
                    } label: {
                        settingsRow(icon: "bell.badge.fill", iconColor: DSColor.info) {
                            HStack {
                                Text("Test Notification")
                                    .font(DSFont.body())
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("Sends in 5s")
                                    .font(DSFont.captionSmall())
                                    .foregroundStyle(DSColor.textTertiary)
                            }
                        }
                    }
                }
            }
            .glassCard(padding: 0)
        }
    }
    
    // MARK: - Google Calendar
    
    private var googleCalendarSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionLabel("GOOGLE CALENDAR")
            
            VStack(spacing: 0) {
                // Connection row
                settingsRow(
                    icon: calService.isConnected ? "checkmark.circle.fill" : "calendar",
                    iconColor: calService.isConnected ? DSColor.success : Color(red: 0.26, green: 0.52, blue: 0.96)
                ) {
                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                            Text("Google Calendar")
                                .font(DSFont.body())
                                .foregroundStyle(.white)
                            
                            if calService.isConnected, let email = calService.userEmail {
                                Text(email)
                                    .font(.system(size: 11))
                                    .foregroundStyle(DSColor.textTertiary)
                            } else {
                                Text("Connect to sync events across all devices")
                                    .font(.system(size: 11))
                                    .foregroundStyle(DSColor.textTertiary)
                            }
                        }
                        
                        Spacer()
                        
                        if calService.isConnected {
                            Text("Connected")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(DSColor.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(DSColor.success.opacity(0.12)))
                        } else {
                            Button {
                                DSHaptics.medium()
                                isConnecting = true
                                Task {
                                    let success = await authService.connectGoogleCalendar()
                                    isConnecting = false
                                    if success {
                                        settings.isCalendarSyncEnabled = true
                                    }
                                }
                            } label: {
                                if isConnecting {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.7)
                                        .frame(width: 70, height: 28)
                                        .background(Capsule().fill(Color(red: 0.26, green: 0.52, blue: 0.96)))
                                } else {
                                    Text("Connect")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(Color(red: 0.26, green: 0.52, blue: 0.96)))
                                }
                            }
                        }
                    }
                }
                
                if calService.isConnected {
                    settingsDivider
                    
                    // Auto sync toggle
                    settingsRow(icon: "arrow.triangle.2.circlepath", iconColor: DSColor.accent) {
                        HStack {
                            Text("Auto Sync")
                                .font(DSFont.body())
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $settings.isCalendarSyncEnabled)
                                .labelsHidden()
                                .tint(DSColor.success)
                        }
                    }
                    
                    settingsDivider
                    
                    // Sync now button
                    Button {
                        DSHaptics.medium()
                        Task {
                            await calService.performSync()
                            syncMessage = "Synced \(calService.syncedEventCount) events"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { syncMessage = nil }
                        }
                    } label: {
                        settingsRow(icon: "arrow.clockwise", iconColor: DSColor.mint) {
                            HStack {
                                VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                                    Text("Sync Now")
                                        .font(DSFont.body())
                                        .foregroundStyle(.white)
                                    if let last = calService.lastSyncDate {
                                        Text("Last: \(last, format: .dateTime.hour().minute())")
                                            .font(DSFont.captionSmall())
                                            .foregroundStyle(DSColor.textTertiary)
                                    }
                                }
                                Spacer()
                                
                                if calService.isSyncing {
                                    ProgressView()
                                        .tint(DSColor.accent)
                                        .scaleEffect(0.8)
                                } else if let msg = syncMessage {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                        Text(msg)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundStyle(DSColor.success)
                                    .transition(.opacity)
                                }
                            }
                        }
                    }
                    
                    settingsDivider
                    
                    // Disconnect
                    Button {
                        DSHaptics.light()
                        authService.disconnectGoogleCalendar()
                        settings.isCalendarSyncEnabled = false
                    } label: {
                        settingsRow(icon: "xmark.circle", iconColor: DSColor.error.opacity(0.7)) {
                            HStack {
                                Text("Disconnect")
                                    .font(DSFont.body())
                                    .foregroundStyle(DSColor.error.opacity(0.8))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .glassCard(padding: 0)
            .animation(DSAnimation.easeMedium, value: calService.isConnected)
            
            // Info tip
            HStack(alignment: .top, spacing: DSSpacing.xs) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                Text("Events sync directly with your Google Calendar account, accessible from any device — iOS, Android, or web.")
                    .font(.system(size: 11))
            }
            .foregroundStyle(DSColor.textTertiary)
            .padding(.horizontal, DSSpacing.xs)
        }
    }
    
    // MARK: - Account
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionLabel("ACCOUNT")
            
            VStack(spacing: 0) {
                settingsRow(icon: "crown.fill", iconColor: DSColor.amber) {
                    HStack {
                        Text("Manage Subscription")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
                
                settingsDivider
                
                settingsRow(icon: "square.and.arrow.up", iconColor: DSColor.info) {
                    HStack {
                        Text("Export Data")
                            .font(DSFont.body())
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
                
                settingsDivider
                
                Button {
                    DSHaptics.light()
                    showSignOutAlert = true
                } label: {
                    settingsRow(icon: "arrow.right.square", iconColor: DSColor.error) {
                        HStack {
                            Text("Sign Out")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.error)
                            Spacer()
                        }
                    }
                }
            }
            .glassCard(padding: 0)
        }
    }
    
    // MARK: - Helpers
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(DSFont.captionSmall())
            .foregroundStyle(DSColor.textTertiary)
            .padding(.leading, DSSpacing.xs)
    }
    
    private func settingsRow<Content: View>(icon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor.opacity(0.12))
                )
            
            content()
        }
        .padding(DSSpacing.md)
    }
    
    private var settingsDivider: some View {
        Divider()
            .overlay(DSColor.cardBorder)
            .padding(.leading, 56)
    }
}

#Preview {
    SettingsView()
}
