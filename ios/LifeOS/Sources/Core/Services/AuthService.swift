import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import GoogleSignIn

@Observable
final class AuthService {
    static let shared = AuthService()
    
    var currentUser: User? {
        didSet {
            // Update analytics when user changes
            if let user = currentUser {
                AnalyticsManager.setUserID(user.uid)
                AnalyticsManager.setUserProperty(user.email, forName: "email")
            } else {
                AnalyticsManager.setUserID(nil)
            }
        }
    }
    
    var isSignedIn: Bool { currentUser != nil }
    var isLoading = true
    var errorMessage: String? {
        didSet {
            if let msg = errorMessage {
                Logger.e("Auth error: \(msg)", category: .auth)
            }
        }
    }
    
    /// Google access token for Calendar API — available after Google Sign-In
    var googleAccessToken: String?
    var isGoogleConnected: Bool { googleAccessToken != nil }
    
    var displayName: String {
        currentUser?.displayName ?? currentUser?.email?.components(separatedBy: "@").first ?? "User"
    }
    
    var email: String {
        currentUser?.email ?? ""
    }
    
    var initials: String {
        let name = displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        Logger.i("Initializing AuthService", category: .auth)
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isLoading = false
        }
        // Restore Google token if previously signed in with Google
        restoreGoogleSignIn()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Google Sign-In
    
    /// Sign in with Google (for auth + calendar access)
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Firebase client ID"
            isLoading = false
            return
        }
        
        guard let windowScene = await MainActor.run(body: {
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        }),
        let rootVC = await MainActor.run(body: {
            windowScene.windows.first?.rootViewController
        }) else {
            errorMessage = "Cannot find root view controller"
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            // Request calendar scope for Google Calendar API access
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVC,
                hint: nil,
                additionalScopes: ["https://www.googleapis.com/auth/calendar"]
            )
            
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                errorMessage = "Missing Google ID token"
                isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            
            
            // Store access token for Calendar API
            await MainActor.run {
                googleAccessToken = user.accessToken.tokenString
                let calService = GoogleCalendarService.shared
                calService.accessToken = user.accessToken.tokenString
                calService.userEmail = user.profile?.email
            }
            
            AnalyticsManager.logEvent(.login, parameters: ["method": "google"])
            Logger.i("Successfully signed in with Google | User: \(user.profile?.email ?? "")", category: .auth)
            
        } catch {
            if (error as NSError).code != GIDSignInError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    
    /// Connect Google Calendar only (user already signed in via other method)
    func connectGoogleCalendar() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        
        guard let windowScene = await MainActor.run(body: {
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        }),
        let rootVC = await MainActor.run(body: {
            windowScene.windows.first?.rootViewController
        }) else { return false }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVC,
                hint: nil,
                additionalScopes: ["https://www.googleapis.com/auth/calendar"]
            )
            
            let user = result.user
            await MainActor.run {
                googleAccessToken = user.accessToken.tokenString
                let calService = GoogleCalendarService.shared
                calService.accessToken = user.accessToken.tokenString
                calService.userEmail = user.profile?.email
            }
            return true
        } catch {
            return false
        }
    }
    
    /// Refresh Google token if expired
    func refreshGoogleToken() async {
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            try await user.refreshTokensIfNeeded()
            await MainActor.run {
                googleAccessToken = user.accessToken.tokenString
                GoogleCalendarService.shared.accessToken = user.accessToken.tokenString
            }
            Logger.d("Google token refreshed successfully", category: .auth)
        } catch {
            Logger.w("Token refresh failed: \(error.localizedDescription)", category: .auth)
            await MainActor.run {
                googleAccessToken = nil
                GoogleCalendarService.shared.disconnect()
            }
        }
    }
    
    /// Restore Google session on app launch
    private func restoreGoogleSignIn() {
        Task {
            do {
                let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                // Check if calendar scope is granted
                let hasCalendarScope = user.grantedScopes?.contains("https://www.googleapis.com/auth/calendar") ?? false
                if hasCalendarScope {
                    try await user.refreshTokensIfNeeded()
                    await MainActor.run {
                        googleAccessToken = user.accessToken.tokenString
                        let calService = GoogleCalendarService.shared
                        calService.accessToken = user.accessToken.tokenString
                        calService.userEmail = user.profile?.email
                    }
                }
            } catch {
                // No previous Google sign-in, that's fine
            }
        }
    }
    
    /// Disconnect Google Calendar
    func disconnectGoogleCalendar() {
        googleAccessToken = nil
        GoogleCalendarService.shared.disconnect()
    }
    
    // MARK: - Email/Password
    
    func signInWithEmail(_ email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            AnalyticsManager.logEvent(.login, parameters: ["method": "email"])
            Logger.i("Successfully signed in with Email", category: .auth)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signUpWithEmail(_ email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            currentUser = Auth.auth().currentUser
            AnalyticsManager.logEvent(.signUp, parameters: ["method": "email"])
            Logger.i("Successfully signed up with Email", category: .auth)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Sign in with Apple
    
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, nonce: String) async {
        isLoading = true
        errorMessage = nil
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = "Unable to process Apple Sign In"
                isLoading = false
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                if let fullName = appleIDCredential.fullName {
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !name.isEmpty && authResult.user.displayName == nil {
                        let changeRequest = authResult.user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        try? await changeRequest.commitChanges()
                    }
                }
                currentUser = Auth.auth().currentUser
                AnalyticsManager.logEvent(.login, parameters: ["method": "apple"])
                Logger.i("Successfully signed in with Apple", category: .auth)
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            googleAccessToken = nil
            GoogleCalendarService.shared.disconnect()
            currentUser = nil
            AnalyticsManager.logEvent(.logout)
            Logger.i("User signed out successfully", category: .auth)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Password Reset
    
    func sendPasswordReset(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Apple Sign In Nonce Helpers

import CryptoKit

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { charset[Int($0) % charset.count] })
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}
