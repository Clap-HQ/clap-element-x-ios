//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Base client for REST API calls with common request/response handling
class RESTAPIClient {
    let homeserverURL: String
    let accessTokenProvider: () -> String?
    let session: URLSession

    /// The base URL with trailing slash removed
    var baseURL: String {
        homeserverURL.hasSuffix("/") ? String(homeserverURL.dropLast()) : homeserverURL
    }

    /// The homeserver domain extracted from the URL
    var homeserverDomain: String {
        URL(string: homeserverURL)?.host ?? homeserverURL
    }

    init(homeserverURL: String, accessTokenProvider: @escaping () -> String?, session: URLSession = .shared) {
        self.homeserverURL = homeserverURL
        self.accessTokenProvider = accessTokenProvider
        self.session = session
    }

    // MARK: - Request Execution

    /// Executes a request and decodes the response
    func execute<T: Decodable>(_ request: RESTAPIRequest) async -> Result<T, RESTAPIError> {
        let result = await executeRaw(request)
        switch result {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
            } catch {
                MXLog.error("Failed to decode response: \(error)")
                return .failure(.decodingError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Executes a request without expecting a response body
    func execute(_ request: RESTAPIRequest) async -> Result<Void, RESTAPIError> {
        let result = await executeRaw(request)
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Private

    private func executeRaw(_ request: RESTAPIRequest) async -> Result<Data, RESTAPIError> {
        guard let url = request.buildURL(baseURL: baseURL) else {
            MXLog.error("Invalid URL for request: \(request.pathTemplate)")
            return .failure(.invalidURL)
        }

        guard let accessToken = accessTokenProvider() else {
            MXLog.error("No access token available")
            return .failure(.unauthorized)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if let body = request.body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                MXLog.error("Failed to encode request body: \(error)")
                return .failure(.encodingError)
            }
        }

        MXLog.debug("Executing \(request.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.dataWithRetry(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            return handleResponse(httpResponse: httpResponse, data: data, context: request.pathTemplate)
        } catch {
            MXLog.error("Network error for \(request.pathTemplate): \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }

    private func handleResponse(httpResponse: HTTPURLResponse, data: Data, context: String) -> Result<Data, RESTAPIError> {
        switch httpResponse.statusCode {
        case 200...299:
            MXLog.info("Successfully completed request: \(context)")
            return .success(data)
        case 401:
            MXLog.error("Unauthorized: \(context)")
            return .failure(.unauthorized)
        case 403:
            MXLog.error("Forbidden: \(context)")
            return .failure(.forbidden)
        case 404:
            MXLog.error("Not found: \(context)")
            return .failure(.notFound)
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            MXLog.error("HTTP \(httpResponse.statusCode) for \(context): \(errorMessage)")
            return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMessage))
        }
    }
}

// MARK: - Request Types

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct RESTAPIRequest {
    let method: HTTPMethod
    let pathTemplate: String
    let pathParameters: [String]
    let queryParameters: [String: String]
    let body: AnyEncodable?

    /// Creates a request with path parameters that will be automatically percent-encoded
    /// - Parameters:
    ///   - method: HTTP method
    ///   - pathTemplate: Path with %@ placeholders for parameters (e.g., "/_clap/client/v1/spaces/%@/remove")
    ///   - pathParameters: Values to substitute for %@ placeholders (will be percent-encoded)
    ///   - queryParameters: Query string parameters (will be properly URL-encoded via URLComponents)
    ///   - body: Optional request body
    init(method: HTTPMethod,
         pathTemplate: String,
         pathParameters: [String] = [],
         queryParameters: [String: String] = [:],
         body: (some Encodable)? = Optional<EmptyBody>.none) {
        self.method = method
        self.pathTemplate = pathTemplate
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.body = body.map { AnyEncodable($0) }
    }

    func buildURL(baseURL: String) -> URL? {
        var path = pathTemplate
        for parameter in pathParameters {
            guard let encoded = parameter.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                return nil
            }
            if let range = path.range(of: "%@") {
                path.replaceSubrange(range, with: encoded)
            }
        }

        // Use URLComponents for proper query parameter encoding
        guard var components = URLComponents(string: "\(baseURL)\(path)") else {
            return nil
        }

        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        return components.url
    }
}

/// Type-erased Encodable wrapper
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        encodeFunc = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

/// Empty body for requests without payload
struct EmptyBody: Encodable { }
