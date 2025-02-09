//
//  mapRowView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import SwiftUI

struct mapRowView: View {
    var map: Map

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: map.map_image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 70)
                        .clipped()
                        .cornerRadius(8)
                        .padding(8)
                } else {
                    ProgressView()
                }
            }


            VStack(alignment: .leading) {
                Text(map.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(map.version)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(map.mapper)
                    .font(.caption)
                    .foregroundColor(.white)
                Text("\(String(format: "%.2f", map.star_rating)) ⭐")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            Spacer()
        }
        .background(Color(red: 57/255, green: 66/255, blue: 70/255))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
    }
}

//struct mapRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        mapRowView(map: MockMapData.maps[1])
//            .previewLayout(.sizeThatFits)
//            
//    }
//}
