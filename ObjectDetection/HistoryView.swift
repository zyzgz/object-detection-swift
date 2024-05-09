//
//  HistoryView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import SwiftUI

struct HistoryView: View {
    let scannedObjects: [ScannedObject]

    var body: some View {
        List(scannedObjects) { object in
            VStack(alignment: .leading) {
                Text(object.classification)
                    .font(.headline)
                Text("\(String(format: "%.2f", object.confidence))%")
                    .font(.subheadline)
                Text(object.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Scanned Objects History")
    }
}

#Preview {
    HistoryView(scannedObjects: [ScannedObject(classification: "Cat",
                                               confidence: 85.7,
                                               date: Date())])
}
