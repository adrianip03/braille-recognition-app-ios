//
//  InferenceView.swift
//  BrailleApp
//
//  Created by adrian on 7/1/2026.
//

import SwiftUI
import SwiftData

struct InferenceView: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var result: InferenceResult? = nil
    @State private var isLoading: Bool = false
    @State private var inpaintedUIImage: UIImage? = nil
    @Environment(\.modelContext) private var context
    
    private func maxOffset(with scale: CGFloat) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let imageWidth = screenWidth * scale
        let imageHeight = screenHeight * scale
        
        return CGSize(width: imageWidth / 2, height: imageHeight / 2)
    }
    
    private func saveTranslationRecord(braille: String, text: String) {
        let newTranslationRecord = TranslationRecord(braille: braille, text: text, direction: .brailleToText)
        context.insert(newTranslationRecord)
        try? context.save()
    }
    
    //data in png format
    private func getInferenceResults(data: Data) async -> InferenceResult? {
        let apiURL = Env.apiURL
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.timeoutInterval = Env.apiTimeout
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let startTime = Date()
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            let responseTime = Date().timeIntervalSince(startTime)
            print(responseTime)
            
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: responseData)
            
            print(apiResponse)
            if apiResponse.message == "No braille characters detected" {
                print("No braille detected")
                return nil
            }
            
            if let inpaintedImg = apiResponse.inpaintedImage,
               inpaintedImg.encoding == "base64"{
                if let uiInpaintedImg = decodeBase64Image(inpaintedImg.data) {
                    DispatchQueue.main.async {
                        self.inpaintedUIImage = uiInpaintedImg
                    }
                }
            }
            
            return InferenceResult(from: apiResponse, imageSize: image.size)
        } catch {
            print("Error: \(error)")
            return nil
        }

    }
    
    private func decodeBase64Image(_ base64: String) -> UIImage? {
        guard let imgData = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: imgData)
    }
    
    private func startInference() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            guard let data = image.pngData() else {
                print("sth wrong")
                return
            }
            if let inferenceResult = await getInferenceResults(data: data) {
                result = inferenceResult
                saveTranslationRecord(braille: inferenceResult.braille, text: inferenceResult.text)
            }
    
        }
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Image(uiImage: inpaintedUIImage ?? image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .scaleEffect(scale)
                .offset(offset)
                .overlay {
                    if let result = result {
                        resultsOverlay(result: result)
                    }
                }
            
        }
        .onAppear {
            startInference()
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let newScale = lastScale * value
                    scale = min(max(newScale, 0.5), 5.0)
                    
                    let currentMaxOffset = maxOffset(with: scale)
                    
                    offset = CGSize(
                        width: max(min(offset.width, currentMaxOffset.width), -currentMaxOffset.width),
                        height: max(min(offset.height, currentMaxOffset.height), -currentMaxOffset.height)
                    )
                    
                    lastOffset = offset
                }
                .onEnded { _ in
                    lastScale = scale
                    
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                    let currentMaxOffset = maxOffset(with: scale)
                    
                    offset = CGSize(
                        width: max(min(newOffset.width, currentMaxOffset.width), -currentMaxOffset.width),
                        height: max(min(newOffset.height, currentMaxOffset.height), -currentMaxOffset.height)
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    withAnimation(.spring()) {
                        if (scale != 1.0 || offset != .zero) {
                            scale = 1.0
                            offset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private func resultsOverlay(result: InferenceResult) -> some View {
        
        let text = result.text
        let box = result.boundingBox
        
        GeometryReader { geometry in
            ZStack {
//                Rectangle()
//                    .fill(Color.black.opacity(0.3))
//                    .edgesIgnoringSafeArea(.all)
            
                Text(text)
                    .font(.system(size: calcFontSize(text: text, containerSize: geometry.size)))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
                    .padding(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .textSelection(.enabled)
                
            }
            .frame(
                width: geometry.size.width * box.width,
                height: geometry.size.height * box.height,
            )
            .position(
                x: geometry.size.width * box.origin.x + (geometry.size.width * box.width) / 2,
                y: geometry.size.height * box.origin.y + (geometry.size.height * box.height) / 2
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(true)
        .scaleEffect(scale)
        .offset(offset)
    }
    
    private func calcFontSize(text: String, containerSize: CGSize) -> CGFloat {
        let charCount = text.count
        let boxArea = containerSize.width * containerSize.height
        
        let fontSize = min(42, max(5, (boxArea / CGFloat(charCount)) * 2))
        return fontSize
    }
    
}


