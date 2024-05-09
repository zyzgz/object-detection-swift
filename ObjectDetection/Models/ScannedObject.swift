//
//  ScannedObject.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import Foundation

struct ScannedObject: Identifiable {
    let id = UUID()
    let classification: String
    let confidence: Float
    let date: Date
}
