//
//  ARCoordinator.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 13/05/2024.
//

import SwiftUI
import ARKit
import SceneKit
import AVKit
import CoreData

class ARCoordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {

    @Binding var sessionMessage: String
    @Binding var isSessionActive: Bool

    var managedObjectContext: NSManagedObjectContext

    let objectDetectionService: ObjectDetectionService
    let throttlerService: ThrottlerService
    var sceneView: ARSCNView?
    var isLoopShouldContinue = false
    var lastLocation: SCNVector3?
    var cachedIsSessionActive: Bool?

    init(objectDetectionService: ObjectDetectionService,
         throttlerService: ThrottlerService,
         sceneView: ARSCNView,
         sessionMessage: Binding<String>,
         isSessionActive: Binding<Bool>,
         managedObjectContext: NSManagedObjectContext) {
        self.objectDetectionService = objectDetectionService
        self.throttlerService = throttlerService
        self.sceneView = sceneView
        self.managedObjectContext = managedObjectContext
        _sessionMessage = sessionMessage
        _isSessionActive = isSessionActive

        super.init()
    }

    func loopObjectDetection() {
        throttlerService.throttle { [weak self] in
            guard let self = self else { return }

            if self.isLoopShouldContinue && self.isSessionActive {
                self.performDetection()
            }
            self.loopObjectDetection()
        }
    }

    func performDetection() {
        guard let pixelBuffer = sceneView?.session.currentFrame?.capturedImage else {
            updateSessionMessage("Camera frame is unavailable.")
            return
        }

        objectDetectionService.detect(on: .init(pixelBuffer: pixelBuffer)) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let response):
                    self.handleDetectionSuccess(response)
                case .failure(let error):
                    self.handleDetectionError(error)
                    break
            }
        }
    }

    private func handleDetectionSuccess(_ response: ObjectDetectionService.Response) {
        if let rectOfInterest = rectOfInterest(for: response.boundingBox) {
            let confidencePercent = response.confidence * 100
            let text = "\(response.classification) \(String(format: "%.2f", confidencePercent))%"
            
            let annotationAdded = addAnnotation(rectOfInterest: rectOfInterest, text: text)

            if annotationAdded {
                DataController().addScannedObject(classification: response.classification,
                                                  confidence: confidencePercent,
                                                  thumbnail: extractObjectImage(from: response.boundingBox)!,
                                                  context: managedObjectContext)
                updateSessionMessage("")
            }
        }
    }

    private func handleDetectionError(_ error: Error) {
        if let recognitionError = error as? RecognitionError {
            switch recognitionError {
                case .invalidImageData:
                    updateSessionMessage("Invalid image data provided.")
                case .resultIsEmpty:
                    updateSessionMessage("No objects detected.")
                case .lowConfidence:
                    updateSessionMessage("Confidence too low to display.")
                case .unexpectedError(let message):
                    updateSessionMessage(message)
                default:
                    updateSessionMessage("An unknown error occurred.")
            }
        } else {
            updateSessionMessage("An error occurred: \(error.localizedDescription)")
        }
    }

    func rectOfInterest(for boundingBox: CGRect) -> CGRect? {
        guard let sceneView = sceneView else { return nil }
        return VNImageRectForNormalizedRect(boundingBox, Int(sceneView.bounds.width), Int(sceneView.bounds.height))
    }

    func addAnnotation(rectOfInterest rect: CGRect, text: String) -> Bool {
        let point = CGPoint(x: rect.midX, y: rect.midY)
        guard let sceneView = sceneView,
              let raycastQuery = sceneView.raycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal),
              let raycastResult = sceneView.session.raycast(raycastQuery).first,
              let cameraPosition = sceneView.pointOfView?.position else { return false }

        let position = SCNVector3(raycastResult.worldTransform.columns.3.x,
                                  raycastResult.worldTransform.columns.3.y,
                                  raycastResult.worldTransform.columns.3.z)
        let distance = (position - cameraPosition).length()

        if distance > 0.5 { return false }

        if !sceneView.isNode(named: AnnotationNode.name, atPoint: point) {
            let bubbleNode = AnnotationNode(text: text)
            bubbleNode.worldPosition = position
            sceneView.prepare([bubbleNode]) { [weak self] success in
                if success {
                    self?.sceneView?.scene.rootNode.addChildNode(bubbleNode)
                }
            }
            return true
        }
        return false
    }
    
    func extractObjectImage(from boundingBox: CGRect) -> UIImage? {
        guard let pixelBuffer = sceneView?.session.currentFrame?.capturedImage else {
            return nil
        }
        
        guard let fullImage = pixelBufferToUIImage(pixelBuffer, rotate: 270) else {
            return nil
        }
        
        let width = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let rect = VNImageRectForNormalizedRect(boundingBox, Int(width), Int(height))
        
        guard let croppedCGImage = fullImage.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage)
    }


    func pixelBufferToUIImage(_ pixelBuffer: CVPixelBuffer, rotate degree: Double) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: CGFloat(degree * .pi / 180))

        let rotatedCIImage = ciImage.transformed(by: transform)

        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(rotatedCIImage, from: rotatedCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }


    private func onSessionUpdate(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        isLoopShouldContinue = false

        switch trackingState {
            case .normal where frame.anchors.isEmpty:
                updateSessionMessage("Move your device.")
            case .notAvailable:
                updateSessionMessage("AR tracking unavailable.")
            case .limited(.excessiveMotion):
                updateSessionMessage("Slow down your movement.")
            case .limited(.insufficientFeatures):
                updateSessionMessage("Need more visible details.")
            case .limited(.initializing):
                updateSessionMessage("Starting AR session...")
            default:
                updateSessionMessage("")
                isLoopShouldContinue = true
                loopObjectDetection()
        }
    }

    private func updateSessionMessage(_ message: String) {
        DispatchQueue.main.async {
            self.sessionMessage = message
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: camera.trackingState)
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = SCNMatrix4(frame.camera.transform)
        let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location

        if let lastLocation = lastLocation {
            let speed = (lastLocation - currentPositionOfCamera).length()
            isLoopShouldContinue = speed < 0.0025 && isSessionActive
        }
        lastLocation = currentPositionOfCamera
    }
}
