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
    
    @Binding var recognizedObject: String
    let model: VNCoreMLModel
    let confidenceThreshold: Float = 0.5
    
    init(recognizedObject: Binding<String>) {
        _recognizedObject = recognizedObject
        guard let resnet50Model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else {
            fatalError("Failed to load ResNet50 model")
        }
        self.model = resnet50Model
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(cameraView: self)
    }
    
    func makeUIViewController(context: Context) -> CameraVC {
        CameraVC(cameraDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: CameraVC, context: Context) {}
    
    final class Coordinator: NSObject, CameraVCDelegate {
        
        private let cameraView: CameraView
    
        init(cameraView: CameraView) {
            self.cameraView = cameraView
        }
        
        func captured(image: CVPixelBuffer) {
            let request = VNCoreMLRequest(model: cameraView.model) {
                (finishedReq, err) in
            
                guard let results = finishedReq.results as? [VNClassificationObservation] else {
                    return
                }
                
                for observation in results {
                    if observation.confidence >= self.cameraView.confidenceThreshold {
                        DispatchQueue.main.async {
                            self.cameraView.recognizedObject = observation.identifier
                        }
                    }
                }
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
    CameraView(recognizedObject: .constant("example object"))
}
