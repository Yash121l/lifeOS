import SwiftUI

struct ContentView: View {
    @State private var authService = AuthService.shared
    @State private var firestoreService = FirestoreService.shared
    @State private var network = NetworkMonitor.shared
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.isLoading {
                // Splash / loading
                ZStack {
                    DSColor.background.ignoresSafeArea()
                    VStack(spacing: DSSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(DSGradient.accent)
                                .frame(width: 64, height: 64)
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .glowShadow(DSColor.accent)
                        
                        ProgressView()
                            .tint(DSColor.accent)
                    }
                }
            } else if authService.isSignedIn {
                ZStack(alignment: .bottom) {
                    mainTabView
                        .onAppear {
                            if let uid = authService.currentUser?.uid {
                                firestoreService.startListening(for: uid)
                            }
                        }
                        .onDisappear {
                            firestoreService.stopListening()
                        }
                    
                    // Offline / Online banners — positioned above tab bar
                    networkBanner
                        .padding(.bottom, 60)
                }
            } else {
                AuthGateView()
            }
        }
        .animation(DSAnimation.easeMedium, value: authService.isSignedIn)
        .animation(DSAnimation.easeMedium, value: authService.isLoading)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Network Banner
    
    @ViewBuilder
    private var networkBanner: some View {
        if !network.isConnected {
            // Offline banner
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 12, weight: .semibold))
                
                Text("You're offline")
                    .font(.system(size: 13, weight: .semibold))
                
                Spacer()
                
                if network.hasPendingWrites {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 10))
                        Text("Changes saved locally")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(Color(hex: "E17055"))
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(DSAnimation.springQuick, value: network.isConnected)
        } else if network.showReconnectedBanner {
            // Back online banner
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "wifi")
                    .font(.system(size: 12, weight: .semibold))
                Text("Back online — syncing changes")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.success)
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(DSAnimation.springQuick, value: network.showReconnectedBanner)
        }
    }
    
    // MARK: - Tab View
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: DSIcon.dashboard)
                }
                .tag(0)
            
            TimeView()
                .tabItem {
                    Label("Time", systemImage: DSIcon.time)
                }
                .tag(1)
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: DSIcon.tasks)
                }
                .tag(2)
            
            FinanceView()
                .tabItem {
                    Label("Finance", systemImage: DSIcon.finance)
                }
                .tag(3)
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: DSIcon.knowledge)
                }
                .tag(4)
        }
        .tint(DSColor.accent)
    }
}

#Preview {
    ContentView()
}
