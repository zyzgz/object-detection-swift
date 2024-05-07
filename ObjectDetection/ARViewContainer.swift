//
//  ARViewContainer.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 24/04/2024.
//

import SwiftUI
import ARKit
import SceneKit
import AVKit

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var sessionMessage: String
    
    let objectDetectionService = ObjectDetectionService()
    let throttler = Throttler(minimumDelay: 1, queue: .global(qos: .userInteractive))
    var sceneView = ARSCNView()
       
    func makeUIView(context: Context) -> ARSCNView {
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints]
           
        startSession()
        
        context.coordinator.sessionMessage = $sessionMessage.wrappedValue
       
        return sceneView
    }
       
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
       
       
    func startSession(resetTracking: Bool = false) {
        guard ARWorldTrackingConfiguration.isSupported else {
            assertionFailure("ARKit is not supported")
            return
        }
           
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
           
        if resetTracking {
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            sceneView.session.run(configuration)
        }
    }
       
    func stopSession() {
        sceneView.session.pause()
    }
       
    func makeCoordinator() -> Coordinator {
        Coordinator(objectDetectionService: objectDetectionService, 
                    throttler: throttler,
                    sceneView: sceneView,
                    sessionMessage: $sessionMessage)
    }
       
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        
        @Binding var sessionMessage: String
        
        let objectDetectionService: ObjectDetectionService
        let throttler: Throttler
        var sceneView: ARSCNView?
        var isLoopShouldContinue = false
        var lastLocation: SCNVector3?

        init(objectDetectionService: ObjectDetectionService,
             throttler: Throttler,
             sceneView: ARSCNView,
             sessionMessage: Binding<String>) {
            
            self.objectDetectionService = objectDetectionService
            self.throttler = throttler
            self.sceneView = sceneView
            _sessionMessage = sessionMessage
            
            super.init()
        }
        
        func loopObjectDetection() {
            throttler.throttle { [weak self] in
                guard let self = self else { return }
                
                if self.isLoopShouldContinue {
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
                        self.handleSuccessfulDetection(response)
                    case .failure(let error):
                        self.handleDetectionError(error)
                    }
            }
        }
        
        private func handleSuccessfulDetection(_ response: ObjectDetectionService.Response) {
            if let rectOfInterest = rectOfInterest(for: response.boundingBox) {
                addAnnotation(rectOfInterest: rectOfInterest, text: response.classification)
                let confidencePercent = response.confidence * 100
                let message = "\(response.classification) with \(String(format: "%.2f", confidencePercent))% confidence"
                updateSessionMessage(message)
            } else {
                updateSessionMessage("Detected object could not be annotated.")
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
        
        func addAnnotation(rectOfInterest rect: CGRect, text: String) {
            let point = CGPoint(x: rect.midX, y: rect.midY)
            guard let sceneView = sceneView,
                  let raycastQuery = sceneView.raycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal),
                  let raycastResult = sceneView.session.raycast(raycastQuery).first,
                  let cameraPosition = sceneView.pointOfView?.position else { return }

            let position = SCNVector3(raycastResult.worldTransform.columns.3.x,
                                      raycastResult.worldTransform.columns.3.y,
                                      raycastResult.worldTransform.columns.3.z)
            let distance = (position - cameraPosition).length()
            
            if distance > 0.5 { return }

            if !sceneView.isNode(named: BubbleNode.name, atPoint: point) {
                let bubbleNode = BubbleNode(text: text)
                bubbleNode.worldPosition = position
                sceneView.prepare([bubbleNode]) { [weak self] success in
                    if success {
                        self?.sceneView?.scene.rootNode.addChildNode(bubbleNode)
                    }
                }
            }
        }
        
        private func onSessionUpdate(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
            switch trackingState {
            case .normal where frame.anchors.isEmpty:
                updateSessionMessage("Scan your surroundings.")
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
            
            isLoopShouldContinue = false
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
                isLoopShouldContinue = speed < 0.0025
            }
            lastLocation = currentPositionOfCamera
        }
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func -(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

func +(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}

func /(l: SCNVector3, r: Float) -> SCNVector3 {
    return SCNVector3(l.x / r, l.y / r, l.z / r)
}

extension ARSCNView {
    func isNode(named name: String, atPoint point: CGPoint) -> Bool {
        let hitTestResults = self.hitTest(point, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        return hitTestResults.contains(where: { $0.node.name == name })
    }
}
