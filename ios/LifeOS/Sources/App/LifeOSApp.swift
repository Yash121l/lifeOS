import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    // Track the quick action the user selected
    @Published var shortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Check if launched from a quick action
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            shortcutItem = item
        }
        return true
    }
    
    // Handle quick action when app is running
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.shortcutItem = shortcutItem
        NotificationCenter.default.post(name: .quickActionTriggered, object: shortcutItem)
        completionHandler(true)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle actions
        switch response.actionIdentifier {
        case NotificationManager.joinMeetingAction:
            if let link = userInfo[NotificationManager.eventMeetingLinkKey] as? String,
               let url = URL(string: link) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        case NotificationManager.markCompleteAction:
            if let taskId = userInfo[NotificationManager.taskIdKey] as? String {
                Task { @MainActor in
                    let store = FirestoreService.shared
                    if var task = store.tasks.first(where: { $0.id == taskId }) {
                        task.isCompleted = true
                        let userId = AuthService.shared.currentUser?.uid ?? ""
                        try? await store.saveTask(task, userId: userId)
                    }
                }
            }
        case NotificationManager.snoozeAction:
            // Reschedule 10 min from now
            let content = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
            let request = UNNotificationRequest(identifier: response.notification.request.identifier + "-snoozed", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        default:
            // Default tap — post deep-link notification
            NotificationCenter.default.post(name: .notificationTapped, object: userInfo)
        }
        
        completionHandler()
    }
}

// Notification names for deep linking
extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
    static let quickActionTriggered = Notification.Name("quickActionTriggered")
}

@main
struct LifeOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
        
        // Firestore offline persistence — 100MB local cache
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
        
        // Start network monitoring
        _ = NetworkMonitor.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handle Google Sign-In callback
                    if url.scheme == "com.googleusercontent.apps.116536834156-slm340hod3qac81oiicbvia4r7n3i0p4" {
                        GIDSignIn.sharedInstance.handle(url)
                    }
                }
                .task {
                    // Request notification permission
                    await NotificationManager.shared.requestAuthorization()
                }
        }
        .environmentObject(appDelegate)
    }
}


