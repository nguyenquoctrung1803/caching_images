//
//  Communicator.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//
import Foundation


typealias NetworkResult<T> = Result<T, NetworkError>
typealias NetworkCompletion<T> = (NetworkResult<T>) -> Void

// MARK: - Network Error
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case networkFailure(Error)
    case invalidResponse
    case timeout
    case noInternetConnection
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode response data"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .networkFailure(let error):
            return "Network failure: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .timeout:
            return "Request timeout"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    private func components() -> URLComponents {
        var comp = URLComponents()
        comp.scheme = "https"
        return comp
    }
    
    // MARK: - GET Request
    /// Perform GET request with comprehensive error handling
    /// - Parameters:
    ///   - urlString: The URL string for the request
    ///   - completion: Completion handler with Result type
    func get(urlString: String,
             completion: @escaping NetworkCompletion<Data>) {
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        // Perform request
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            // Check for network errors
            if let error = error {
                self?.handleNetworkError(error, completion: completion)
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Check data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Success
            completion(.success(data))
        }
        
        task.resume()
    }
    
    
    func downloadImage(imageURL: String, completion: @escaping NetworkCompletion<Data>) {
        // Validate URL
        guard let url = URL(string: imageURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.cachePolicy = .returnCacheDataElseLoad
        
        // Perform download task
        let task = session.downloadTask(with: request) { [weak self] localURL, response, error in
            // Check for network errors
            if let error = error {
                self?.handleNetworkError(error, completion: completion)
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Check local URL
            guard let localURL = localURL else {
                completion(.failure(.noData))
                return
            }
            
            // Read data from local file
            do {
                let data = try Data(contentsOf: localURL)
                completion(.success(data))
            } catch {
                completion(.failure(.networkFailure(error)))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Error Handling
    private func handleNetworkError(_ error: Error, completion: @escaping NetworkCompletion<Data>) {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            completion(.failure(.noInternetConnection))
        case NSURLErrorTimedOut:
            completion(.failure(.timeout))
        default:
            completion(.failure(.networkFailure(error)))
        }
    }
}
