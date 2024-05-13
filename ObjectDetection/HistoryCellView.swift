//
//  HistoryCellView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 12/05/2024.
//

import SwiftUI

struct HistoryCellView: View {
    
    var object: ScannedObject
    
    var body: some View {
        HStack {
            if let thumbnailImage = UIImage.from(data: object.thumbnail) {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 90)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(object.classification!)
                    .font(.headline)
                Text("\(String(format: "%.2f", object.confidence))%")
                    .font(.subheadline)
                Text(object.date!, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.leading)
        }
    }
}

extension UIImage {
    static func from(data: Data?) -> UIImage? {
        guard let imageData = data else { return nil }
        return UIImage(data: imageData)
    }
}
