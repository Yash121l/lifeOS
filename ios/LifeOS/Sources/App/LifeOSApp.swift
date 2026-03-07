import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

@main
struct LifeOSApp: App {
    
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
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
