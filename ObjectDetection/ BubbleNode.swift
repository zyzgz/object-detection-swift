//
//   BubbleNode.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 22/04/2024.
//

import SceneKit

class AnnotationNode: SCNNode {
    static let name = String(describing: AnnotationNode.self)
    let annotationDepth: CGFloat = 0.1
    let hiddenGeometry = SCNSphere(radius: 0.15)

    init(text: String) {
        super.init()
        setupTextNode(with: text)
        setupSphereNode()
        setupSearchNode()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextNode(with text: String) {
        let textGeometry = SCNText(string: text, extrusionDepth: annotationDepth)
        textGeometry.font = UIFont(name: "Helvetica-Bold", size: 0.12)
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial = createMaterial()
        textGeometry.chamferRadius = annotationDepth

        let (minBound, maxBound) = textGeometry.boundingBox
        let textNode = SCNNode(geometry: textGeometry)
        textNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, Float(annotationDepth) / 2)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)

        addChildNode(textNode)
    }

    private func setupSphereNode() {
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        addChildNode(sphereNode)
    }

    private func setupSearchNode() {
        let searchNode = SCNNode(geometry: hiddenGeometry)
        searchNode.name = Self.name
        searchNode.eulerAngles.x = -90
        searchNode.geometry?.materials.first?.transparency = 0
        addChildNode(searchNode)
    }

    private func setupConstraints() {
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }

    private func createMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.specular.contents = UIColor.gray
        material.isDoubleSided = true
        return material
    }
}



