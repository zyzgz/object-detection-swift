//
//  CameraViewControllerRepresentable.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedObjects: [String]
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedObjects: $recognizedObjects)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        @Binding var recognizedObjects: [String]
        
        init(recognizedObjects: Binding<[String]>) {
            _recognizedObjects = recognizedObjects
        }
        
        func captured(image: UIImage) {
            // Tutaj można użyć modelu Core ML do rozpoznania obiektów na obrazie
            // i zaktualizować recognizedObjects
            recognizedObjects = ["Example Object 1", "Example Object 2"] // Przykładowe rozpoznane obiekty
        }
    }
}
