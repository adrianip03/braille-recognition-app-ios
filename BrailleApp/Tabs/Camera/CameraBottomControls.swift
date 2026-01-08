//
//  CameraBottomControls.swift
//  BrailleApp
//
//  Created by adrian on 4/1/2026.
//

import SwiftUI
import PhotosUI

struct CameraBottomControls: View {
    let onCapture: () -> Void
    let onGallery: () -> Void
    let captureDisabled: Bool
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                    Button(action: onGallery) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                    }
                    .padding(.leading, 24)
                }
                
                Spacer()
                
                Button(action: onCapture) {
                    ZStack {
                        Circle()
                            .fill(captureDisabled ? Color.gray.opacity(0.3) : Color.white.opacity(0.9))
                            .frame(width: 60, height: 60)
                            .padding(10)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 70, height: 70)
                    }
                }
                .disabled(captureDisabled)
                .scaleEffect(captureDisabled ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: captureDisabled)
                
                Spacer()
                
                // Placeholder for symmetry
                Button(action: {}) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.clear)
                        .padding(12)
                }
                .padding(.trailing, 24)
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
        }
        .frame(height: 130)
    }
}


//#Preview {
//    ZStack {
//        Color.black.ignoresSafeArea()
//        VStack {
//            Spacer()
//            CameraBottomControls(onCapture: {print ("Capture")}, onGallery: {print("Gallery")}, captureDisabled: false)
//        }
//    }
//}
