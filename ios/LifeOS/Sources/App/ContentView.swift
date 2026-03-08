import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var authService = AuthService.shared
    @State private var firestoreService = FirestoreService.shared
    @State private var network = NetworkMonitor.shared
    @State private var selectedTab = 0
    
    // Deep link / notification state
    @State private var notificationPayload: NotificationPayload?
    @State private var showAddTask = false
    @State private var showAddEvent = false
    @State private var showAddNote = false
    
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
        // Deep link handling
        .onOpenURL { url in
            handleDeepLink(url)
        }
        // Notification tap handling
        .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
            if let userInfo = notification.object as? [AnyHashable: Any],
               let payload = NotificationPayload.from(userInfo: userInfo) {
                notificationPayload = payload
            }
        }
        // Quick action handling
        .onReceive(NotificationCenter.default.publisher(for: .quickActionTriggered)) { notification in
            if let item = notification.object as? UIApplicationShortcutItem {
                handleQuickAction(item)
            }
        }
        // Check for quick action on launch
        .onAppear {
            if let item = appDelegate.shortcutItem {
                handleQuickAction(item)
                appDelegate.shortcutItem = nil
            }
        }
        // Notification detail sheet
        .sheet(item: $notificationPayload) { payload in
            NotificationDetailView(payload: payload)
        }
        // Quick action sheets
        .sheet(isPresented: $showAddTask) {
            NavigationStack {
                TaskNLPInputView()
            }
        }
        .sheet(isPresented: $showAddEvent) {
            EventEntryView()
        }
        .sheet(isPresented: $showAddNote) {
            NoteEditorView(note: nil)
        }
    }
    
    // MARK: - Deep Link Handler
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "lifeos" else { return }
        
        switch url.host {
        case "tasks":
            selectedTab = 2
        case "time", "schedule":
            selectedTab = 1
        case "finance":
            selectedTab = 3
        case "notes":
            selectedTab = 4
        case "dashboard":
            selectedTab = 0
        case "addtask":
            selectedTab = 2
            showAddTask = true
        case "addevent":
            selectedTab = 1
            showAddEvent = true
        case "addnote":
            selectedTab = 4
            showAddNote = true
        default:
            break
        }
    }
    
    // MARK: - Quick Action Handler
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) {
        switch item.type {
        case "com.yashlunawat.LifeOS.addTask":
            selectedTab = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showAddTask = true }
        case "com.yashlunawat.LifeOS.addEvent":
            selectedTab = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showAddEvent = true }
        case "com.yashlunawat.LifeOS.viewSchedule":
            selectedTab = 1
        case "com.yashlunawat.LifeOS.quickNote":
            selectedTab = 4
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showAddNote = true }
        default:
            break
        }
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
