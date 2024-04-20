//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraView()
            .frame(maxWidth: .infinity, maxHeight: 300)
    }
}

#Preview {
    ContentView()
}

