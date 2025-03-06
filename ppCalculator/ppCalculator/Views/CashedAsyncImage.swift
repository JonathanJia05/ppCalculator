//
//  CashedAsyncImage.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 3/1/25.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL
    
    var body: some View {
        if let cachedImage = ImageCache.shared.object(forKey: NSString(string: url.absoluteString)) {
            Image(uiImage: cachedImage)
                .resizable()
        } else {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                } else {
                    ProgressView()
                }
            }
        }
    }
}
