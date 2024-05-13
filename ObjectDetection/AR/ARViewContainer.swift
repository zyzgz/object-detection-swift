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
import CoreData

struct ARViewContainer: UIViewRepresentable {

    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var sessionMessage: String
    @Binding var isSessionActive: Bool

    let objectDetectionService = ObjectDetectionService()
    let throttler = ThrottlerService(minimumDelay: 1, queue: .global(qos: .userInteractive))
    var sceneView = ARSCNView()

    func makeUIView(context: Context) -> ARSCNView {
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints]

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if isSessionActive != context.coordinator.cachedIsSessionActive {
            manageSession()
            context.coordinator.cachedIsSessionActive = isSessionActive
        }
    }

    func manageSession() {
        if isSessionActive {
            startSession()
        } else {
            stopSession()
        }
    }

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

    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(objectDetectionService: objectDetectionService,
                    throttler: throttler,
                    sceneView: sceneView,
                    sessionMessage: $sessionMessage,
                    isSessionActive: $isSessionActive,
                    managedObjectContext: managedObjectContext)
    }
}


