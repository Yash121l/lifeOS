import Foundation
import Combine
import SwiftUI

import FirebaseAuth

/// Abstract definitions for our core services to allow mocking and dependency inversion
protocol AuthServiceProtocol: ObservableObject {
    var currentUser: FirebaseAuth.User? { get }
    var isSignedIn: Bool { get }
    var isLoading: Bool { get }
}

protocol DatabaseServiceProtocol: ObservableObject {
    var timeBlocks: [TimeBlock] { get }
    var tasks: [TaskItem] { get }
    var financialTransactions: [TransactionItem] { get }
    var notes: [NoteItem] { get }
    
    func startListening(for userId: String)
    func stopListening()
    // Other functions would go here
}

/// The main Dependency Injection Container that holds all services.
/// We inject this into the environment so views NEVER use singletons directly.
final class DIContainer: ObservableObject {
    static let shared = DIContainer() // Provide a singleton strictly for bootstrapping or legacy migration
    
    @Published var auth: AuthService
    @Published var database: FirestoreService
    let analytics: AnalyticsServiceProtocol
    let remoteConfig: RemoteConfigServiceProtocol
    let apiClient: APIClientProtocol
    
    private init(
        auth: AuthService = .shared,
        database: FirestoreService = .shared,
        analytics: AnalyticsServiceProtocol = AnalyticsService.shared,
        remoteConfig: RemoteConfigServiceProtocol = RemoteConfigService.shared,
        apiClient: APIClientProtocol = APIClient.shared
    ) {
        self.auth = auth
        self.database = database
        self.analytics = analytics
        self.remoteConfig = remoteConfig
        self.apiClient = apiClient
    }
}
