import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
    case decodingError(Error)
    case timeout
    case networkError(Error)
}

protocol APIClientProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequest, retries: Int, initialDelay: TimeInterval) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    
    private let session: URLSession
    
    // Default config with caching and timeout
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 30 sec timeout
        configuration.timeoutIntervalForResource = 60 // 60 sec total
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: configuration)
    }
    
    /// Requests with exponential backoff retry logic
    func request<T: Decodable>(_ urlRequest: URLRequest, retries: Int = 3, initialDelay: TimeInterval = 1.0) async throws -> T {
        var currentDelay = initialDelay
        
        for attempt in 1...retries {
            do {
                print("API Attempt \(attempt) for \(urlRequest.url?.absoluteString ?? "")")
                let (data, response) = try await session.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.badStatusCode(httpResponse.statusCode)
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
                
            } catch {
                if attempt == retries {
                    if let urlError = error as? URLError, urlError.code == .timedOut {
                        throw APIError.timeout
                    }
                    throw APIError.networkError(error)
                }
                // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= 2.0
            }
        }
        
        throw APIError.invalidResponse
    }
}
