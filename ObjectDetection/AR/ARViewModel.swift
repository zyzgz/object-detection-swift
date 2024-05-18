//
//  ContentViewModel.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 18/05/2024.
//

import Foundation

final class ARViewModel: ObservableObject {
    
    @Published var sessionMessage: String = "Looking for surfaces..."
    @Published var isARSessionActive: Bool = true
    
    func startSession() {
        isARSessionActive = true
    }
    
    func stopSession() {
        isARSessionActive = false
    }
    
    func updateMessage(_ message: String) {
        sessionMessage = message
    }
}
