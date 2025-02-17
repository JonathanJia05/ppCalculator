//
//  ApiRequests.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class ApiRequests: ObservableObject {
    @Published var data: [Map] = []
    @Published var pp: Double?
    @Published var feedbackResponse: String = ""
    
    private let baseURLString = "http://127.0.0.1:8000"
    private var token = ""
    private var token_type = ""
    private var client_id: String {
        return Bundle.main.object(forInfoDictionaryKey: "Client_id") as? String ?? ""
    }
    private var authCode: String = ""
    private var codeVerifier: String = ""
    private var isAuthorizing = false
    
    init() {
        loadTokenFromKeychain()
    }

    private func loadTokenFromKeychain() {
        if let tokenData = KeychainHelper.shared.read(service: "com.ppCalculator.auth", account: "jwt"),
           let savedToken = String(data: tokenData, encoding: .utf8) {
            self.token = savedToken
            print("Token loaded from Keychain")
        } else {
            print("No token found in Keychain")
        }
    }

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
        var mutableRequest = request

        if self.token.isEmpty {
            if !isAuthorizing {
                isAuthorizing = true
                print("No token available, authorizing...")
                self.authorize {
                    self.exchangeToken {
                        self.isAuthorizing = false
                        self.performAuthorizedRequest(request, attempt: attempt + 1, completion: completion)
                    }
                }
            } else {
                print("Authorization already in progress, waiting...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performAuthorizedRequest(request, attempt: attempt, completion: completion)
                }
            }
            return
        } else {
            mutableRequest.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: mutableRequest) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                print("401 Unauthorized.")
                if attempt < 2 {
                    self?.authorize {
                        self?.exchangeToken {
                            self?.performAuthorizedRequest(request, attempt: attempt + 1, completion: completion)
                        }
                    }
                    return
                }
            }
            completion(data, response, error)
        }.resume()
    }

    
    private func authorize(completion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(baseURLString)/auth") else {
            print("Auth URL is not valid")
            completion()
            return
        }
        
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        
        self.codeVerifier = codeVerifier
        
        let credentials = AuthRequest(client_id: client_id, code_challenge: codeChallenge, challenge_method: "S256")
        do {
            let jsonData = try JSONEncoder().encode(credentials)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    print("Failed to post auth: \(error?.localizedDescription ?? "Unknown error")")
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
            print("Unable to encode credentials to JSON: \(error)")
            completion()
        }
    }
    
    private func exchangeToken(completion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(baseURLString)/token") else {
            print("Token URL is not valid")
            completion()
            return
        }
        
        let tokenRequest = TokenRequest(client_id: client_id,
                                        auth_code: authCode,
                                        code_verifier: codeVerifier)
        do {
            let jsonData = try JSONEncoder().encode(tokenRequest)
            let request = createRequest(url: url, method: "POST", body: jsonData)
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    print("Failed to exchange token: \(error?.localizedDescription ?? "Unknown error")")
                    completion()
                    return
                }
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.token = tokenResponse.access_token
                        self?.token_type = tokenResponse.token_type
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
            print("Unable to encode token request to JSON: \(error)")
            completion()
        }
    }


    func getMaps(query: String, page: Int, mode: Int, completion: @escaping () -> Void = {}) {
        let encodedQuery = query.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURLString)/searchdb?query=\(encodedQuery)&page=\(page)&mode=\(mode)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion()
            return
        }
        
        let request = createRequest(url: url, method: "GET")
        
        performAuthorizedRequest(request) { [weak self] data, _, error in
            if let error = error {
                print("Failed to fetch maps: \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else {
                print("No data returned from maps API")
                completion()
                return
            }
            do {
                let maps = try JSONDecoder().decode([Map].self, from: data)
                DispatchQueue.main.async {
                    self?.data = maps
                }
            } catch {
                print("Failed to decode maps JSON: \(error.localizedDescription)")
            }
            completion()
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
            print("Unable to encode PPRequest to JSON: \(error)")
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
            print("Unable to encode feedback to JSON: \(error)")
            completion()
        }
    }
}
