//
//  DetailView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 12/05/2024.
//

import SwiftUI

struct DetailView: View {
    
    var object: ScannedObject
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let thumbnailImage = UIImage.from(data: object.thumbnail) {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                }
                
                Group {
                    Text("Classification")
                        .font(.headline)
                        .padding(.top)

                    Text(object.classification ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom)

                    Text("Confidence")
                        .font(.headline)

                    Text("\(String(format: "%.2f%%", object.confidence))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom)

                    Text("Date")
                        .font(.headline)

                    if let date = object.date {
                        Text(date, style: .date)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                    } else {
                        Text("Unknown date")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

