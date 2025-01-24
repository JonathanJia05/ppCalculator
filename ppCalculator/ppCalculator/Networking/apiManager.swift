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
}

