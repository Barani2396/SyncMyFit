//
//  FitbitAuthManager.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-06-30.
//

import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

// MARK: - FitbitAuthManager

/// Manages OAuth authentication with Fitbit using PKCE, token exchange, refresh, and secure token storage.
class FitbitAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: - Singleton

    static let shared = FitbitAuthManager()

    // MARK: - Properties

    private let clientId = Secrets.shared.fitbitClientID
    private let redirectURI = "syncmyfit://auth"
    private var currentSession: ASWebAuthenticationSession?
    private var codeVerifier: String = ""

    /// Exposes the stored access token publicly (read-only).
    var accessToken: String? {
        storedAccessToken
    }

    // MARK: - OAuth Login Flow

    /// Initiates Fitbit OAuth flow using PKCE.
    func startLogin(completion: @escaping (Result<String, Error>) -> Void) {
        codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        let scope = "activity heartrate profile sleep"

        let authURL = URL(string:
            "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=\(clientId)&code_challenge=\(codeChallenge)&code_challenge_method=S256&redirect_uri=\(redirectURI)&scope=\(scope)&expires_in=604800"
        )!

        currentSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "syncmyfit"
        ) { callbackURL, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let callbackURL = callbackURL,
                  let code = self.extractCode(from: callbackURL) else {
                completion(.failure(NSError(domain: "FitbitAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get code"])))
                return
            }

            completion(.success(code))
        }

        currentSession?.presentationContextProvider = self
        currentSession?.prefersEphemeralWebBrowserSession = true
        currentSession?.start()
    }

    // MARK: - Token Exchange

    /// Exchanges the authorization code for an access token and stores it securely.
    func fetchAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.fitbit.com/oauth2/token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "client_id": clientId,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI,
            "code": authCode,
            "code_verifier": codeVerifier
        ]

        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1)))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                if let accessToken = json?["access_token"] as? String {
                    self.storedAccessToken = accessToken

                    if let refreshToken = json?["refresh_token"] as? String {
                        self.storedRefreshToken = refreshToken
                    }

                    if let expiresIn = json?["expires_in"] as? Double {
                        let expiresAt = Date().addingTimeInterval(expiresIn)
                        UserDefaults.standard.set(expiresAt, forKey: "fitbit_token_expires_at")
                    }

                    completion(.success(accessToken))
                } else if let errors = json?["errors"] as? [[String: Any]] {
                    print("Fitbit API Error: \(errors)")
                    completion(.failure(NSError(domain: "Fitbit error", code: -2)))
                } else {
                    completion(.failure(NSError(domain: "Unexpected token response", code: -3)))
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Token Refresh

    /// Refreshes the Fitbit access token using the stored refresh token.
    func refreshAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = storedRefreshToken,
              let url = URL(string: "https://api.fitbit.com/oauth2/token") else {
            return completion(.failure(NSError(domain: "Missing refresh token", code: -1)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1)))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                if let newAccessToken = json?["access_token"] as? String {
                    self.storedAccessToken = newAccessToken

                    if let newRefreshToken = json?["refresh_token"] as? String {
                        self.storedRefreshToken = newRefreshToken
                    }

                    if let expiresIn = json?["expires_in"] as? Double {
                        let expiresAt = Date().addingTimeInterval(expiresIn)
                        UserDefaults.standard.set(expiresAt, forKey: "fitbit_token_expires_at")
                    }

                    completion(.success(newAccessToken))
                } else if let errors = json?["errors"] as? [[String: Any]] {
                    print("Fitbit API Error: \(errors)")
                    completion(.failure(NSError(domain: "Fitbit error", code: -2)))
                } else {
                    completion(.failure(NSError(domain: "Unexpected token response", code: -3)))
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Authorized Requests

    /// Sends a request with the current access token.
    /// Automatically refreshes token once if expired.
    func performAuthenticatedRequest(
        _ request: URLRequest,
        retryOnAuthFailure: Bool = true,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var request = request

        guard let token = storedAccessToken else {
            return completion(.failure(NSError(domain: "No access token", code: 401)))
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401, retryOnAuthFailure {
                self.refreshAccessToken { result in
                    switch result {
                    case .success:
                        self.performAuthenticatedRequest(request, retryOnAuthFailure: false, completion: completion)
                    case .failure(let refreshError):
                        completion(.failure(refreshError))
                    }
                }
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "Unknown response", code: -1)))
            }
        }.resume()
    }

    // MARK: - Redirect Handler

    /// Handles the redirect URL and triggers token exchange.
    func handleRedirectURL(_ url: URL) {
        guard let code = extractCode(from: url) else {
            print("No authorization code in URL")
            return
        }

        print("Authorization Code: \(code)")
        fetchAccessToken(authCode: code) { result in
            switch result {
            case .success(let token): print("Access Token: \(token)")
            case .failure(let error): print("Token exchange failed: \(error)")
            }
        }
    }

    // MARK: - Presentation Anchor (ASWebAuthenticationSession)

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    // MARK: - PKCE Utility

    private func generateCodeVerifier() -> String {
        let charset = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<128).compactMap { _ in charset.randomElement() })
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let hashed = SHA256.hash(data: Data(verifier.utf8))
        return Data(hashed).base64URLEncodedString()
    }

    private func extractCode(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: true)?
            .queryItems?.first(where: { $0.name == "code" })?.value
    }

    func isTokenValid() -> Bool {
        guard let expiresAt = UserDefaults.standard.object(forKey: "fitbit_token_expires_at") as? Date else {
            return false
        }
        return Date() < expiresAt
    }
}

// MARK: - Keychain Accessors

extension FitbitAuthManager {
    private var accessTokenKey: String { "fitbit_access_token" }
    private var refreshTokenKey: String { "fitbit_refresh_token" }
    private var service: String { "com.syncmyfit.token" }

    var storedAccessToken: String? {
        get {
            guard let data = KeychainHelper.shared.read(service: service, account: accessTokenKey) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            if let token = newValue {
                KeychainHelper.shared.save(Data(token.utf8), service: service, account: accessTokenKey)
            } else {
                KeychainHelper.shared.delete(service: service, account: accessTokenKey)
            }
        }
    }

    var storedRefreshToken: String? {
        get {
            guard let data = KeychainHelper.shared.read(service: service, account: refreshTokenKey) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            if let token = newValue {
                KeychainHelper.shared.save(Data(token.utf8), service: service, account: refreshTokenKey)
            } else {
                KeychainHelper.shared.delete(service: service, account: refreshTokenKey)
            }
        }
    }

    /// Clears stored tokens from the Keychain.
    func logout() {
        storedAccessToken = nil
        storedRefreshToken = nil
    }
}

// MARK: - Base64 URL Encoding

extension Data {
    /// Encodes data into base64 URL-safe format (used for PKCE challenge).
    func base64URLEncodedString() -> String {
        self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
