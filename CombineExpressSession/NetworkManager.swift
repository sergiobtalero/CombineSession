//
//  NetworkManager.swift
//  CombineExpressSession
//
//  Created by Sergio Bravo Talero on 20/01/23.
//

import Foundation
import Combine

final class NetworkManager {
    private let urlSession: URLSession
    
    // MARK: - Initializer
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Methods
    func fetchResponse<T: Decodable>(url: String,
                                     completion: @escaping (Result<T, NetworkManager.SimulatedError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.example))
            return
        }
        
        urlSession.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(.example))
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let decodedObject = try jsonDecoder.decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodeFailed))
            }
        }
        .resume()
    }
    
    func fetchResponse<T: Decodable>(url: String) -> AnyPublisher<T, NetworkManager.SimulatedError> {
        guard let url = URL(string: url) else {
            return Fail<T, NetworkManager.SimulatedError>(error: .example)
                .eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { result in
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: result.data)
            }
            .mapError { _ in SimulatedError.decodeFailed }
            .eraseToAnyPublisher()
    }
}

// MARK: - Errors
extension NetworkManager {
    enum SimulatedError: Error {
        case example
        case decodeFailed
    }
}
