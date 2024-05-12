//
//  MessageOverlay.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import SwiftUI

struct MessageOverlay: View {
    
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            Text(message)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.8))
                .shadow(radius: 10)
        )
        .transition(.slide)
        .animation(.easeInOut, value: message)
    }
}

#Preview {
    MessageOverlay(message: "example text")
}
