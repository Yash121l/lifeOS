import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var settings = SettingsManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    
                    // MARK: - Preferences
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("PREFERENCES")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.leading, DSSpacing.xs)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Currency")
                                    .font(DSFont.body())
                                    .foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                Picker("Currency", selection: $settings.currencyCode) {
                                    ForEach(settings.availableCurrencies, id: \.self) { code in
                                        Text(code).tag(code)
                                    }
                                }
                                .tint(DSColor.accent)
                                .labelsHidden()
                            }
                            .padding(DSSpacing.md)
                            
                            Divider().overlay(DSColor.cardBorder)
                            
                            HStack {
                                Text("Timezone")
                                    .font(DSFont.body())
                                    .foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                Picker("Timezone", selection: $settings.timezone) {
                                    ForEach(settings.availableTimezones, id: \.self) { tz in
                                        Text(tz.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? tz).tag(tz)
                                    }
                                }
                                .tint(DSColor.accent)
                                .labelsHidden()
                            }
                            .padding(DSSpacing.md)
                        }
                        .glassCard(padding: 0)
                    }
                    
                    // MARK: - Integrations
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("INTEGRATIONS")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.leading, DSSpacing.xs)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(DSColor.accent)
                                    .font(.system(size: 20))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                                    Text("Calendar Sync")
                                        .font(DSFont.body())
                                        .foregroundStyle(DSColor.textPrimary)
                                    Text("Sync tasks and blocks with iOS Calendar (supports Google via iOS Settings)")
                                        .font(DSFont.captionSmall())
                                        .foregroundStyle(DSColor.textTertiary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Toggle("Calendar Sync", isOn: $settings.isCalendarSyncEnabled)
                                    .labelsHidden()
                                    .tint(DSColor.success)
                            }
                            .padding(DSSpacing.md)
                        }
                        .glassCard(padding: 0)
                    }
                    
                    // MARK: - Account
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("ACCOUNT & ACCESS")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.leading, DSSpacing.xs)
                        
                        VStack(spacing: 0) {
                            Button {
                                DSHaptics.selection()
                            } label: {
                                HStack {
                                    Text("Manage Subscription")
                                        .font(DSFont.body())
                                        .foregroundStyle(DSColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(DSColor.textTertiary)
                                }
                                .padding(DSSpacing.md)
                            }
                            
                            Divider().overlay(DSColor.cardBorder)
                            
                            Button {
                                DSHaptics.selection()
                            } label: {
                                HStack {
                                    Text("Export Data")
                                        .font(DSFont.body())
                                        .foregroundStyle(DSColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16))
                                        .foregroundStyle(DSColor.textTertiary)
                                }
                                .padding(DSSpacing.md)
                            }
                            
                            Divider().overlay(DSColor.cardBorder)
                            
                            Button {
                                DSHaptics.light()
                            } label: {
                                HStack {
                                    Text("Sign Out")
                                        .font(DSFont.body())
                                        .foregroundStyle(DSColor.error)
                                    Spacer()
                                }
                                .padding(DSSpacing.md)
                            }
                        }
                        .glassCard(padding: 0)
                    }
                    
                    Text("LifeOS Version 1.0.0")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                        .padding(.top, DSSpacing.xl)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(DSFont.headline())
                    .foregroundStyle(DSColor.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
}
