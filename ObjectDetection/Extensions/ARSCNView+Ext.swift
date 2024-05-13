//
//  ARSCNView+Ext.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 13/05/2024.
//

import ARKit

extension ARSCNView {
    func isNode(named name: String, atPoint point: CGPoint) -> Bool {
        let hitTestResults = self.hitTest(point, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        return hitTestResults.contains(where: { $0.node.name == name })
    }
}
