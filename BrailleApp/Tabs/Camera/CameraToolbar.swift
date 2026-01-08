//
//  CameraToolBar.swift
//  BrailleApp
//
//  Created by adrian on 4/1/2026.
//

import SwiftUI
import AVFoundation

extension View{
    
    func cameraToolBar(
        flashMode: AVCaptureDevice.FlashMode,
        onExit: @escaping () -> Void,
        onFlashToggle: @escaping () -> Void
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onFlashToggle) {
                        Image(systemName: flashIconName(for: flashMode))
                            .foregroundColor(.white)
                    }
                }
            }
    }
    
    private func flashIconName(for flashMode: AVCaptureDevice.FlashMode) -> String {
        switch flashMode {
        case .off:
            return "bolt.slash.fill"
        case .on:
            return "bolt.fill"
        case .auto:
            return "bolt.badge.automatic.fill"
        @unknown default:
            return "bolt.slash.fill"
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
