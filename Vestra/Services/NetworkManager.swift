//
//  NetworkManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 17/5/2026.
//

import Foundation
import Combine

// Defining the API Endpoint protocol
protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: [String: String] { get }
}

// Enum of HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// Enum of API Errors
enum APIError: Error {
    case invalidResponse
    case invalidData
    case invalidURL
}

// Enum used to create the property endpoint
enum PropertyEndpoint: APIEndpoint {
    case getProperty(streetNumber: String, streetName: String, suburb: String, state: String, postcode: String)
    
    var baseURL: URL {
        return URL(string: "http://localhost:8000")!
    }
    
    var path: String {
        switch self {
        case .getProperty:
            return "/property/lookup"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProperty:
            return .post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getProperty:
            return ["Authorization": "Default"]
        }
    }
    
    var body: [String : String] {
        switch self {
        case .getProperty(let streetNumber, let streetName, let suburb, let state, let postcode):
            return ["street_number": streetNumber, "street_name": streetName, "suburb": suburb, "state": state, "postcode": postcode]
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if endpoint.method == .post {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(endpoint.body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
