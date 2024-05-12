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
            if let thumbnail = object.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 90)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(object.classification)
                    .font(.headline)
                Text("\(String(format: "%.2f", object.confidence))%")
                    .font(.subheadline)
                Text(object.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.leading)
        }
    }
}

#Preview {
    HistoryCellView(object: ScannedObject(classification: "Cat",
                                  confidence: 85.7,
                                  date: Date(),
                                  thumbnail: UIImage(named: "placeholder")))
}
