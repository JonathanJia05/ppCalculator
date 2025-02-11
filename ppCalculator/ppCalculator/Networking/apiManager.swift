//
//  apiManager.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class ApiRequests : ObservableObject{
    @Published var data: [Map] = []
    @Published var pp: Double?
    @Published var feedbackResponse: String = ""
    private var baseURL = "http://127.0.0.1:8000"
    
    func getMaps(query: String, page: Int, mode: Int, completion: @escaping () -> Void = {}) {
        let baseURL = "\(baseURL)/searchdb"
        let encodedQuery = query.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?query=\(encodedQuery)&page=\(page)&mode=\(mode)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Failed to fetch maps: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
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
        .resume()
    }
    
    func getPP(with ppRequest: PPRequest, completion: @escaping () -> Void = {}) {
        
        guard let baseURL = URL(string: "\(baseURL)/calculate") else {
            print("url is not valid")
            return
        }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(ppRequest)
            request.httpBody = jsonData
        } catch {
            print("Unable to encode PPRequest to JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to post: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            do {
                let getPP = try JSONDecoder().decode(PPResponse.self, from: data)
                self?.pp = getPP.pp
                print("PP decoded")
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
            completion()
        }
        .resume()
        
    }
    
    func sendFeedback(with feedback: Feedback, completion: @escaping () -> Void = {}) {
        guard let baseURL = URL(string: "\(baseURL)/feedback") else {
            print("url is not valid")
            return
        }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(feedback)
            request.httpBody = jsonData
        } catch {
            print("Unable to send feedback")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to post: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            do {
                let feedbackResponse = try JSONDecoder().decode(FeedbackResponse.self, from: data)
                self?.feedbackResponse = feedbackResponse.message
                print("Response received")
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
            completion()
        }
        .resume()
    }
}


