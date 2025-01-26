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
    
    func getMaps(from url: URL, completion: @escaping () -> Void = {}) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            
            do {
                let maps = try JSONDecoder().decode([Map].self, from: data)
                self?.data = maps
                print("Fetched and decoded maps")
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
            completion()
        }
        .resume()
    }
    
    func getPP(with ppRequest: PPRequest, completion: @escaping () -> Void = {}) {
        
        guard let baseURL = URL(string: "http://127.0.0.1:8000/calculate") else {
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
}


