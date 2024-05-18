//
//  HistoryViewModel.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 18/05/2024.
//

import SwiftUI
import CoreData
import Combine

final class HistoryViewModel: ObservableObject {
    
    @Published var scannedObjects: [ScannedObject] = []
    @Published var selectedObject: ScannedObject? = nil
    @Published var errorMessage: String?
    @Published var isShowingAlert = false
    
    init() {
        fetchScannedObjects()
        observeDataControllerErrors()
    }
    
    func fetchScannedObjects() {
        scannedObjects = DataController.shared.fetchScannedObjects()
    }
    
    func deleteObject(at offsets: IndexSet) {
        withAnimation {
            offsets.map { scannedObjects[$0] }
                .forEach { DataController.shared.deleteObject(object: $0) }
            
            fetchScannedObjects()
        }
    }
    
    func selectObject(_ object: ScannedObject) {
        selectedObject = object
    }
    
    private func observeDataControllerErrors() {
        DataController.shared.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                    self?.isShowingAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
