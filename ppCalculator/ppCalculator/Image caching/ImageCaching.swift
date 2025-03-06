//
//  ImageCaching.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 3/1/25.
//

import UIKit

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}
