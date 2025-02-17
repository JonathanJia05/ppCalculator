//
//  Authentication.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/16/25.
//

import Foundation
import CryptoKit

func generateCodeVerifier() -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
    return String((0..<64).compactMap { _ in characters.randomElement() })
}

func generateCodeChallenge(from codeVerifier: String) -> String {
    let data = Data(codeVerifier.utf8)
    let hash = SHA256.hash(data: data)
    let challenge = Data(hash).base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    return challenge
}
