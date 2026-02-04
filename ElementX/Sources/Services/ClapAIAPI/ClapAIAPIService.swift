//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class ClapAIAPIService: ClapAIAPIServiceProtocol {
    private let clapAIServerURL: String
    private let userID: String
    private let matrixAccessTokenProvider: () -> String?
    private let keychainController: KeychainControllerProtocol
    private let session: URLSession
    
    private var isExchangingToken = false
    private let tokenRefreshMargin: TimeInterval = 300
    
    private(set) var currentUser: ClapAIUser?
    
    private var baseURL: String {
        clapAIServerURL.hasSuffix("/") ? String(clapAIServerURL.dropLast()) : clapAIServerURL
    }
    
    private var cachedToken: ClapAIToken? {
        keychainController.clapAIToken(forUsername: userID)
    }
    
    private var jwtToken: String? {
        cachedToken?.accessToken
    }
    
    private var isTokenValid: Bool {
        guard let token = cachedToken else { return false }
        return !token.accessToken.isEmpty && Date() < token.expiresAt.addingTimeInterval(-tokenRefreshMargin)
    }

    private(set) lazy var schedules: ClapAIScheduleAPIProtocol = ClapAIScheduleAPI(
        homeserverURL: clapAIServerURL,
        accessTokenProvider: { [weak self] in self?.jwtToken },
        tokenRefresher: { [weak self] in await self?.exchangeToken() ?? .failure(.unauthorized) },
        session: session
    )

    init(clapAIServerURL: String,
         userID: String,
         matrixAccessTokenProvider: @escaping () -> String?,
         keychainController: KeychainControllerProtocol,
         session: URLSession = .shared) {
        self.clapAIServerURL = clapAIServerURL
        self.userID = userID
        self.matrixAccessTokenProvider = matrixAccessTokenProvider
        self.keychainController = keychainController
        self.session = session
    }
    
    func ensureAuthenticated() async -> Result<Void, RESTAPIError> {
        if isTokenValid {
            return .success(())
        }
        
        guard !isExchangingToken else {
            return .failure(.unauthorized)
        }
        
        return await exchangeToken()
    }
    
    func invalidateToken() {
        keychainController.removeClapAIToken(forUsername: userID)
        currentUser = nil
    }
    
    func fetchCurrentUser() async -> Result<ClapAIUser, RESTAPIError> {
        guard let token = jwtToken else {
            return .failure(.unauthorized)
        }
        
        guard let url = URL(string: "\(baseURL)/api/auth/me") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let user = try JSONDecoder().decode(ClapAIUser.self, from: data)
                currentUser = user
                MXLog.info("Fetched current user: \(user.userID), role: \(user.role)")
                return .success(user)
            case 401:
                return .failure(.unauthorized)
            case 403:
                return .failure(.forbidden)
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMessage))
            }
        } catch let decodingError as DecodingError {
            MXLog.error("Failed to decode user response: \(decodingError)")
            return .failure(.decodingError)
        } catch {
            MXLog.error("Fetch user network error: \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    private func exchangeToken() async -> Result<Void, RESTAPIError> {
        guard let matrixToken = matrixAccessTokenProvider() else {
            MXLog.error("No Matrix access token available for token exchange")
            return .failure(.unauthorized)
        }
        
        isExchangingToken = true
        defer { isExchangingToken = false }
        
        guard let url = URL(string: "\(baseURL)/api/auth/token-exchange") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = TokenExchangeRequest(matrixToken: matrixToken)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            MXLog.error("Failed to encode token exchange request: \(error)")
            return .failure(.encodingError)
        }
        
        MXLog.debug("Executing token exchange to \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let tokenResponse = try JSONDecoder().decode(TokenExchangeResponse.self, from: data)
                let token = ClapAIToken(
                    accessToken: tokenResponse.accessToken,
                    expiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
                )
                keychainController.setClapAIToken(token, forUsername: userID)
                MXLog.info("Token exchange successful, expires in \(tokenResponse.expiresIn)s")
                return .success(())
            case 401:
                MXLog.error("Token exchange unauthorized")
                return .failure(.unauthorized)
            case 403:
                MXLog.error("Token exchange forbidden")
                return .failure(.forbidden)
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                MXLog.error("Token exchange failed with status \(httpResponse.statusCode): \(errorMessage)")
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMessage))
            }
        } catch let decodingError as DecodingError {
            MXLog.error("Failed to decode token exchange response: \(decodingError)")
            return .failure(.decodingError)
        } catch {
            MXLog.error("Token exchange network error: \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
}

// MARK: - ClapAIRESTAPIClient

class ClapAIRESTAPIClient: RESTAPIClient {
    private let tokenRefresher: () async -> Result<Void, RESTAPIError>
    private var isRefreshing = false
    
    init(homeserverURL: String,
         accessTokenProvider: @escaping () -> String?,
         tokenRefresher: @escaping () async -> Result<Void, RESTAPIError>,
         session: URLSession = .shared) {
        self.tokenRefresher = tokenRefresher
        super.init(homeserverURL: homeserverURL, accessTokenProvider: accessTokenProvider, session: session)
    }
    
    override func execute<T: Decodable>(_ request: RESTAPIRequest) async -> Result<T, RESTAPIError> {
        let result: Result<T, RESTAPIError> = await super.execute(request)
        return await retryIfUnauthorized(result, request: request) {
            await super.execute(request)
        }
    }
    
    override func execute(_ request: RESTAPIRequest) async -> Result<Void, RESTAPIError> {
        let result = await super.execute(request)
        return await retryIfUnauthorized(result, request: request) {
            await super.execute(request)
        }
    }
    
    private func retryIfUnauthorized<T>(
        _ result: Result<T, RESTAPIError>,
        request: RESTAPIRequest,
        retry: () async -> Result<T, RESTAPIError>
    ) async -> Result<T, RESTAPIError> {
        guard case .failure(.unauthorized) = result, !isRefreshing else {
            return result
        }
        
        isRefreshing = true
        let refreshResult = await tokenRefresher()
        isRefreshing = false
        
        guard case .success = refreshResult else {
            return result
        }
        
        MXLog.info("Token refreshed, retrying request: \(request.pathTemplate)")
        return await retry()
    }
}

// MARK: - Token Exchange

private struct TokenExchangeRequest: Encodable {
    let matrixToken: String
    
    enum CodingKeys: String, CodingKey {
        case matrixToken = "matrix_token"
    }
}

private struct TokenExchangeResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
