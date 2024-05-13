//
//  UIImage+Ext.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 13/05/2024.
//

import SwiftUI

extension UIImage {
    static func from(data: Data?) -> UIImage? {
        guard let imageData = data else { return nil }
        return UIImage(data: imageData)
    }
}
