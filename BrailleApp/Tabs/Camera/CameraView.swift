import SwiftUI
import Photos
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showCapturedImage = false
    @State private var isCapturing = false
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    @State private var selectedItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var navigateToInferece = false
    @State private var focusPoint: CGPoint?
    @State private var showFocusAnimation = false
    
    let onExit: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview
                CameraPreview(cameraManager: cameraManager)
                    .ignoresSafeArea()
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                cameraManager.handleZoom(value.magnification)
                            }
                    )
                    .simultaneousGesture(
                        SpatialTapGesture(count: 1)
                            .onEnded { value in
                                let location = value.location
                                focus(at: location)
                            }
                    )
                
                // focus animation
                if let focusPoint = focusPoint, showFocusAnimation {
                    FocusAnimationView(focusPoint: focusPoint)
                        .transition(.opacity)
                }
                
                // Overlay
                VStack {
                    
                    Spacer()
                    
                    CameraBottomControls(
                        onCapture: capturePhoto,
                        onGallery: openGallery,
                        captureDisabled: isCapturing
                    )
                }
                
                // Captured Image Preview
//                if let capturedImage = capturedImage, showCapturedImage {
//                    CapturedImageView(image: capturedImage)
//                        .transition(.opacity)
//                        .onAppear {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                withAnimation {
//                                    self.showCapturedImage = false
//                                }
//                            }
//                        }
//                }
            }
            .navigationDestination(
                isPresented: $navigateToInferece,
                destination: {
                    if let image = capturedImage {
                        InferenceView(image: image)
                        
                    }
                }
            )
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItem,
    //            maxSelectionCount: 1,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedItem) {
                Task {
                    guard let item = selectedItem else {return}
                    
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data:data) {
                        capturedImage = image
                        showPhotoPicker = false
                        navigateToInferece = true
                        selectedItem = nil
                    }
                }
                
            }
            .cameraToolBar(
                flashMode: flashMode,
                onExit: onExit,
                onFlashToggle: toggleFlash
            )
            .onAppear {
                cameraManager.setUpCaptureSession()
                checkCameraPermissions()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            
        }
    }
    
    private func focus(at point: CGPoint) {
        
        cameraManager.focus(at: point)
        
        
        withAnimation(.easeOut(duration: 0.1)) {
            focusPoint = point
            showFocusAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.3)) {
                showFocusAnimation = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusPoint = nil
            }
        }
    }
    
    private func capturePhoto() {
        guard !isCapturing else { return }
        
        isCapturing = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            // Visual feedback
        }
        
        cameraManager.capturePhoto(flashMode: flashMode) { image, error in
            DispatchQueue.main.async {
                isCapturing = false
                
                if let error = error {
                    print("Capture error: \(error.localizedDescription)")
                    return
                }
                
                if let image = image {
                    capturedImage = image
//                    showCapturedImage = true
                    navigateToInferece = true
                }
            }
        }
    }
    
    private func toggleFlash() {
        switch flashMode {
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        case .auto:
            flashMode = .off
        @unknown default:
            flashMode = .off
        }
    }
    
    private func openGallery() {
        showPhotoPicker = true
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraManager.startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    cameraManager.startSession()
                } else {
                    showPermissionAlert()
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert() {
        // TODO: Show permission alert using SwiftUI Alert
    }
}

// MARK: - Focus Animation View
struct FocusAnimationView: View {
    let focusPoint: CGPoint
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .stroke(Color.white, lineWidth: 2)
            .background(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
            )
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(focusPoint)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 1.0
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                    opacity = 0
                }
            }
    }
}


// MARK: - Camera Preview View
struct CameraPreview: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // Set up preview layer
        DispatchQueue.main.async {
            cameraManager.setUpPreviewLayer(in: view)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update frame when view bounds change
        DispatchQueue.main.async {
            cameraManager.updatePreviewLayer(frame: uiView.bounds)
        }
    }
}

// MARK: - Captured Image View
//struct CapturedImageView: View {
//    let image: UIImage
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 80, height: 80)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.white, lineWidth: 2)
//                    )
//                    .padding()
//            }
//        }
//        .animation(.default, value: image)
//    }
//}

#Preview {
    NavigationStack{
        CameraView(
            onExit: {
                print("Exit camera")
            }
        )
    }
}


