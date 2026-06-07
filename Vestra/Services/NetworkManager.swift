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
    var body: Encodable? { get }
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

// Type-erasure wrapper so `Encodable?` (an existential) can be passed to
// `JSONEncoder.encode<T: Encodable>(_:)` which expects a concrete type.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ value: Encodable) {
        self._encode = value.encode(to:)
    }
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// Enum used to create the property endpoint
enum PropertyEndpoint: APIEndpoint {
    /// Fire-and-forget enrichment request. Backend enqueues a scrape job and
    /// the worker writes the enriched data straight into Firestore.
    case enrichProperty(uid: String, pageId: String, address: Address)

    struct Address: Codable {
        let streetNumber: String
        let streetName: String
        let suburb: String
        let state: String
        let postcode: String

        enum CodingKeys: String, CodingKey {
            case streetNumber = "street_number"
            case streetName = "street_name"
            case suburb
            case state
            case postcode
        }
    }

    struct EnrichBody: Codable {
        let uid: String
        let pageId: String
        let address: Address

        enum CodingKeys: String, CodingKey {
            case uid
            case pageId = "page_id"
            case address
        }
    }

    var baseURL: URL {
        URL(string: "http://localhost:8000")!
    }

    var path: String {
        switch self {
        case .enrichProperty: return "/property/enrich"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .enrichProperty: return .post
        }
    }

    var headers: [String: String]? {
        switch self {
        case .enrichProperty: return nil
        }
    }

    var body: Encodable? {
        switch self {
        case .enrichProperty(let uid, let pageId, let address):
            return EnrichBody(uid: uid, pageId: pageId, address: address)
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()

    /// Fire-and-forget HTTP request. Returns when the server acknowledges (2xx);
    /// throws if it doesn't.
    func request(_ endpoint: APIEndpoint) async throws {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = endpoint.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
}
