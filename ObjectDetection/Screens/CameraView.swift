//
//  CameraView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct CameraView: View {
    
    @State private var recognizedObjects: [String] = []
    
    var body: some View {
        NavigationView{
            VStack{
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                
                Spacer()
                    .frame(height: 60)
                
                VStack {
                    Label("Rozpoznane obiekty:", systemImage: "eye")
                        .font(.title2)
                    
                    if recognizedObjects.isEmpty {
                        Text("Brak rozpoznanych obiektów.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(recognizedObjects, id: \.self) { object in
                            Text(object)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("🕵🏻‍♂️ Rozpoznaj")
        }
    }
}

#Preview {
    CameraView()
}
