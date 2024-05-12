//
//  HistoryViewModel.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 12/05/2024.
//

import Foundation

class HistoryViewModel: ObservableObject {
    
    @Published var scannedObjects: [ScannedObject] = []
    @Published var selectedObject: ScannedObject?
    @Published var isShowingDetail = false
    
    func deleteItems(at offsets: IndexSet) {
        scannedObjects.remove(atOffsets: offsets)
    }
}
