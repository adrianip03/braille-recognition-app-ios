import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    // MARK: - Properties
    
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    private var captureDevice: AVCaptureDevice?
    
    private var initialZoom: CGFloat = 1.0
    @Published var currentZoom: CGFloat = 1.0
    private var minimumZoom: CGFloat = 1.0
    private var maximumZoom: CGFloat = 5.0
    
    private var focusAnimationView: UIView?
    
    var photoCaptureCompletion: ((UIImage?, Error?) -> Void)?
    
    // MARK: - SwiftUI Compatible Methods
    
    func setUpCaptureSession() {
        guard !captureSession.isRunning else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        setUpDevices()
        setUpInputs()
        setUpPhotoOutput()
        
        captureSession.commitConfiguration()
    }
    
    private func setUpDevices() {
        guard let defaultVideoDevice = AVCaptureDevice.default(for: .video) else {
            // TODO: raise error for not finding camera
            return
        }
        captureDevice = defaultVideoDevice
    }
    
    private func setUpInputs() {
        guard let captureDevice = captureDevice else {
            print("Error: No capture device available")
            return
        }
        
        do {
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            let cameraInput = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
            
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
        }
    }
    
    private func setUpPhotoOutput() {
        // Remove existing photo output if any
        for output in captureSession.outputs {
            if output is AVCapturePhotoOutput {
                captureSession.removeOutput(output)
            }
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }
    
    // MARK: - Preview Layer
    
    func setUpPreviewLayer(in view: UIView) {
        // Remove existing preview layer if any
        previewLayer?.removeFromSuperlayer()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else { return }
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        if #available(iOS 17.0, *) {
            previewLayer.connection?.videoRotationAngle = 90
        } else {
            previewLayer.connection?.videoOrientation = .landscapeRight
        }
        
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func updatePreviewLayer(frame: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer?.frame = frame
        CATransaction.commit()
    }
    
    var isPreviewLayerSet: Bool {
        return previewLayer != nil
    }
    
    // MARK: - SwiftUI Compatible Camera Controls
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        
        // Make sure session is configured first
        if captureSession.inputs.isEmpty {
            setUpCaptureSession()
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }
    
    func toggleFlash() {
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
    
    func setZoom(scale: CGFloat) {
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            let zoomFactor = max(minimumZoom, min(scale, maximumZoom))
            
            device.videoZoomFactor = zoomFactor
            currentZoom = zoomFactor
            
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
    
    // MARK: - SwiftUI Gesture Handling
    
    func handleZoom(_ scale: CGFloat) {
        let zoomScale = min(max(scale, minimumZoom), maximumZoom)
        setZoom(scale: zoomScale)
    }
    
    func handlePinchGesture(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            initialZoom = currentZoom
        case .changed:
            let zoomScale = min(max(pinch.scale * initialZoom, minimumZoom), maximumZoom)
            setZoom(scale: zoomScale)
        default:
            break
        }
    }
    
    func focus(at point: CGPoint) {
        guard let previewLayer = previewLayer else { return }
        
        // Convert SwiftUI coordinates to layer coordinates
        let layerPoint = CGPoint(
            x: point.x,
            y: point.y
        )
        
        focus(at: layerPoint, in: UIView(frame: previewLayer.frame))
    }
    
    func focus(at point: CGPoint, in view: UIView) {
        guard let device = captureDevice,
              let previewLayer = previewLayer else { return }
        
        // Convert preview layer coordinates to camera coordinates
        let cameraPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = cameraPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = cameraPoint
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
            showFocusAnimation(at: point, in: view)
            
        } catch {
            print("Error focusing: \(error)")
        }
    }
    
    private func showFocusAnimation(at point: CGPoint, in view: UIView) {
        // Remove previous animation view if exists
        focusAnimationView?.removeFromSuperview()
        
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.center = point
        focusView.backgroundColor = .clear
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.layer.cornerRadius = 40
        focusView.alpha = 0
        
        focusAnimationView = focusView
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.3, animations: {
            focusView.alpha = 1
            focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                focusView.alpha = 0
                focusView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { _ in
                focusView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Capture Photo
    
    func capturePhoto(completion: @escaping (UIImage?, Error?) -> Void) {
        capturePhoto(flashMode: flashMode, completion: completion)
    }
    
    func capturePhoto(flashMode: AVCaptureDevice.FlashMode, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let connection = photoOutput.connection(with: .video) else {
            completion(nil, NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No camera connection"]))
            return
        }
        
        if #available(iOS 17.0, *) {
            connection.videoRotationAngle = 90
        } else {
            connection.videoOrientation = .landscapeRight
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        if #available(iOS 16.0, *) {
            photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024)
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoCaptureCompletion = completion
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Cleanup
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureCompletion?(nil, error)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(nil, NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from photo data"]))
            return
        }
        
        photoCaptureCompletion?(image, nil)
    }
}
