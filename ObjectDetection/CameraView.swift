//
//  CameraView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 02/04/2024.
//

import SwiftUI
import Vision
import CoreML

struct CameraView: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> CameraVC {
        CameraVC(cameraDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: CameraVC, context: Context) {}
    
    final class Coordinator: NSObject, CameraVCDelegate {
        func captured(image: CVPixelBuffer) {
            guard let model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else {
                        return
            }
            
            let request = VNCoreMLRequest(model: model) {
                (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {
                return
            }
            
            guard let firstObservation = results.first else {
                return
            }
            
            print(firstObservation.identifier,
                  firstObservation.confidence)
        }
            
            do {
                try VNImageRequestHandler(cvPixelBuffer: image, options: [:]).perform([request])
            } catch {
                print("Błąd podczas przetwarzania obrazu.")
            }
        }
        
        func cameraErrorOccurred(_ error: CameraError) {
            print(error.rawValue)
        }
    }
}

#Preview {
    CameraView()
}
