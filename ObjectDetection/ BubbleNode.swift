//
//   BubbleNode.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 22/04/2024.
//

import SceneKit

class BubbleNode: SCNNode {
    static let name = String(describing: BubbleNode.self)
    
    let bubbleDepth: CGFloat = 0.1
    let hiddenGeometry = SCNSphere(radius: 0.15)
    
    init(text: String) {
        super.init()
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        let font = UIFont(name: "Futura", size: 0.15)
        bubble.font = font
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2,
                                                     minBound.y,
                                                     Float(bubbleDepth) / 2)
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        
        let searchNode = SCNNode(geometry: hiddenGeometry)
        searchNode.name = Self.name
        searchNode.eulerAngles.x = -90
        searchNode.geometry?.materials.first?.transparency = 0
        
        addChildNode(bubbleNode)
        addChildNode(sphereNode)
        addChildNode(searchNode)
        bubbleNode.constraints = [billboardConstraint]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
