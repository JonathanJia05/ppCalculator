//
//  ppCalculatorApp.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/22/25.
//

import SwiftUI

@main
struct ppCalculatorApp: App {
    @StateObject private var api = ApiRequests()
    var body: some Scene {
        WindowGroup {
            SearchView()
                .environmentObject(api)
        }
    }
}

