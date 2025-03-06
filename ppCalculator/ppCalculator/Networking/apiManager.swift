//
//  ApiRequests.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class ApiRequests: ObservableObject {
    // Published Properties
    @Published var data: [Map] = []
    @Published var pp: Double?
    @Published var feedbackResponse: String = ""
    @Published var isAuthorized: Bool = false

    // Private Properties
    private let baseURLString = "https://osu-db.com"
    private var token = ""
    private var tokenType = ""
    private var isAuthorizing = false
    
    private var clientID: String {
        Bundle.main.object(forInfoDictionaryKey: "Client_id") as? String ?? ""
    }
    private var authCode = ""
    private var codeVerifier = ""
    
    // Initialization
    init() {
        loadTokenFromKeychain()
    }
    
    // Token Management
    private func loadTokenFromKeychain() {
        if let tokenData = KeychainHelper.shared.read(service: "com.ppCalculator.auth", account: "jwt"),
           let savedToken = String(data: tokenData, encoding: .utf8) {
            token = savedToken
            // Set isAuthorized on the main thread so UI updates correctly
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = true
            }
            print("Token loaded from Keychain")
        } else {
            print("No token found in Keychain")
        }
    }
    
    // Ensures a valid token exists before calling completion handler
    private func ensureToken(completion: @escaping () -> Void) {
        if !token.isEmpty {
            completion()
        } else {
            if !isAuthorizing {
                isAuthorizing = true
                print("No token available, authorizing...")
                authorize { [weak self] in
                    self?.exchangeToken {
                        self?.isAuthorizing = false
                        completion()
                    }
                }
            } else {
                print("Authorization in progress, waiting...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.ensureToken(completion: completion)
                }
            }
        }
    }
    
    // Network Request Helper
    private func createRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    private func performAuthorizedRequest(_ request: URLRequest,
                                            attempt: Int = 1,
                                            completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        ensureToken { [weak self] in
            guard let self = self else { return }
            var authorizedRequest = request
            authorizedRequest.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: authorizedRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 401, attempt < 2 {
                    print("401 Unauthorized. Refreshing token...")
                    self.authorize {
                        self.exchangeToken {
                            self.performAuthorizedRequest(request, attempt: attempt + 1, completion: completion)
                        }
                    }
                    return
                }
                completion(data, response, error)
            }.resume()
        }
    }
    
    // Authorization
    private func authorize(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURLString)/auth") else {
            print("Auth URL is not valid")
            completion()
            return
        }
        
        codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        
        let credentials = AuthRequest(client_id: clientID,
                                      code_challenge: codeChallenge,
                                      challenge_method: "S256")
        do {
            let jsonData = try JSONEncoder().encode(credentials)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                if let error = error {
                    print("Failed to post auth: \(error.localizedDescription)")
                    completion()
                    return
                }
                guard let data = data else {
                    print("No data received from auth endpoint")
                    completion()
                    return
                }
                do {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self?.authCode = authResponse.auth_code
                    print("Auth code received")
                } catch {
                    print("Failed to decode auth JSON: \(error.localizedDescription)")
                }
                completion()
            }.resume()
        } catch {
            print("Failed to encode credentials: \(error.localizedDescription)")
            completion()
        }
    }
    
    private func exchangeToken(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURLString)/token") else {
            print("Token URL is not valid")
            completion()
            return
        }
        
        let tokenRequest = TokenRequest(client_id: clientID,
                                        auth_code: authCode,
                                        code_verifier: codeVerifier)
        do {
            let jsonData = try JSONEncoder().encode(tokenRequest)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                if let error = error {
                    print("Failed to exchange token: \(error.localizedDescription)")
                    completion()
                    return
                }
                guard let data = data else {
                    print("No data received from token endpoint")
                    completion()
                    return
                }
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.token = tokenResponse.access_token
                        self?.tokenType = tokenResponse.token_type
                        self?.isAuthorized = true  // Update isAuthorized here on the main thread
                        print("Token exchanged successfully")
                        if let tokenData = tokenResponse.access_token.data(using: .utf8) {
                            KeychainHelper.shared.save(tokenData,
                                                       service: "com.ppCalculator.auth",
                                                       account: "jwt")
                        }
                    }
                } catch {
                    print("Failed to decode token JSON: \(error.localizedDescription)")
                }
                completion()
            }.resume()
        } catch {
            print("Failed to encode token request: \(error.localizedDescription)")
            completion()
        }
    }
    
    // Endpoints
    func getMaps(query: String, page: Int, mode: Int, completion: @escaping ([Map]) -> Void) {
        let encodedQuery = query.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURLString)/searchdb?query=\(encodedQuery)&page=\(page)&mode=\(mode)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion([])
            return
        }
        
        let request = createRequest(url: url, method: "GET")
        performAuthorizedRequest(request) { data, _, error in
            if let error = error {
                print("Failed to fetch maps: \(error.localizedDescription)")
                completion([])
                return
            }
            guard let data = data else {
                print("No data returned from maps API")
                completion([])
                return
            }
            do {
                let maps = try JSONDecoder().decode([Map].self, from: data)
                DispatchQueue.main.async {
                    completion(maps)
                }
            } catch {
                print("Failed to decode maps JSON: \(error.localizedDescription)")
                completion([])
            }
        }
    }

    
    func getPP(with ppRequest: PPRequest, completion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(baseURLString)/calculate") else {
            print("Calculate URL is not valid")
            completion()
            return
        }
        do {
            let jsonData = try JSONEncoder().encode(ppRequest)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            performAuthorizedRequest(request) { [weak self] data, _, error in
                if let error = error {
                    print("Failed to post PP request: \(error.localizedDescription)")
                    completion()
                    return
                }
                guard let data = data else {
                    print("No data returned from PP API")
                    completion()
                    return
                }
                do {
                    let ppResponse = try JSONDecoder().decode(PPResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.pp = ppResponse.pp
                    }
                    print("PP decoded")
                } catch {
                    print("Failed to decode PP JSON: \(error.localizedDescription)")
                }
                completion()
            }
        } catch {
            print("Failed to encode PPRequest: \(error.localizedDescription)")
            completion()
        }
    }
    
    func sendFeedback(with feedback: Feedback, completion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(baseURLString)/feedback") else {
            print("Feedback URL is not valid")
            completion()
            return
        }
        do {
            let jsonData = try JSONEncoder().encode(feedback)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            performAuthorizedRequest(request) { [weak self] data, _, error in
                if let error = error {
                    print("Failed to send feedback: \(error.localizedDescription)")
                    completion()
                    return
                }
                guard let data = data else {
                    print("No data returned from feedback API")
                    completion()
                    return
                }
                do {
                    let feedbackResponse = try JSONDecoder().decode(FeedbackResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.feedbackResponse = feedbackResponse.message
                    }
                    print("Feedback response received")
                } catch {
                    print("Failed to decode feedback JSON: \(error.localizedDescription)")
                }
                completion()
            }
        } catch {
            print("Failed to encode feedback: \(error.localizedDescription)")
            completion()
        }
    }
}
