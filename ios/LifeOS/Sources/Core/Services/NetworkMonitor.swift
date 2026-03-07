import Foundation
import Network

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected = true
    var connectionType: ConnectionType = .unknown
    
    /// Tracks if data was written while offline (pending sync)
    var hasPendingWrites = false
    
    /// Shows a brief "Back Online" banner after reconnecting
    var showReconnectedBanner = false
    
    enum ConnectionType {
        case wifi, cellular, wired, unknown
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = path.status == .satisfied
                
                // Determine connection type
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .wired
                } else {
                    self?.connectionType = .unknown
                }
                
                // Handle reconnection
                if !wasConnected && path.status == .satisfied {
                    self?.hasPendingWrites = false
                    self?.showReconnectedBanner = true
                    
                    // Auto-hide reconnected banner after 3s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.showReconnectedBanner = false
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Call when a write operation happens while offline
    func markPendingWrite() {
        if !isConnected {
            hasPendingWrites = true
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
