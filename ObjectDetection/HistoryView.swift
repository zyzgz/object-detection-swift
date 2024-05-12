//
//  HistoryView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import SwiftUI

struct HistoryView: View {
    
    @State var scannedObjects: [ScannedObject]
    @State private var selectedObject: ScannedObject?
    @State private var isShowingDetail = false

    var body: some View {
        NavigationView {
            List {
                ForEach(scannedObjects) { object in
                  HistoryCellView(object: object)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        self.selectedObject = object
                        self.isShowingDetail = true
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Recent Scans")
            .listStyle(.plain)
            
            if self.scannedObjects.isEmpty {
                Text("No scans available")
                        .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $isShowingDetail) {
            if let selectedObject = selectedObject {
                DetailView(object: selectedObject)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        scannedObjects.remove(atOffsets: offsets)
    }
}


#Preview {
    HistoryView(scannedObjects: [ScannedObject(classification: "Cat",
                                               confidence: 85.7,
                                               date: Date(),
                                               thumbnail: UIImage(named: "placeholder"))])
}
