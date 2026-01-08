//
//  CameraToolBar.swift
//  BrailleApp
//
//  Created by adrian on 4/1/2026.
//

import SwiftUI
import AVFoundation

extension View{
    
    func inferenceToolBar(
        onExit: @escaping () -> Void,
    ) -> some View {
        self
            .navigationTitle(Text(""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onExit) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("BrailleApp")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
            }
    }
    
}

//#Preview {
//    ZStack {
//        Color.black.ignoresSafeArea()
//        VStack {
//            CameraTopToolBar(onExit: {})
//            Spacer()
//        }
//    }
//}
