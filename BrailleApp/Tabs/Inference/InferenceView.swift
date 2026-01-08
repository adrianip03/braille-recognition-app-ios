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
    
    //mock api
    private func getInferenceResults(data: Data) async -> InferenceResult? {
        // send png to api
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        //dummy result
        let result = InferenceResult(
            braille: "⠇⠕⠗⠑⠍ ⠊⠏⠎⠥⠍ ⠙⠕⠇⠕⠗ ⠎⠊⠞ ⠁⠍⠑⠞⠂ ⠉⠕⠝⠎⠑⠉⠞⠑⠞⠥⠗ ⠁⠙⠊⠏⠊⠎⠉⠊⠝⠛ ⠑⠇⠊⠞⠲ ⠍⠕⠗⠃⠊ ⠉⠕⠍⠍⠕⠙⠕ ⠎⠑⠍ ⠁⠗⠉⠥⠂ ⠋⠁⠥⠉⠊⠃⠥⠎ ⠁⠥⠉⠞⠕⠗ ⠁⠥⠛⠥⠑ ⠎⠁⠛⠊⠞⠞⠊⠎ ⠑⠞⠲",
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi commodo sem arcu, faucibus auctor augue sagittis et.",
            confidence: 0.9,
            boundingBox: CGRect(x: 100, y: 100, width: 200, height: 50)
        )
        return result

    }
    
    private func startInference() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            if let data = image.pngData(){
                if let inferenceResult = await getInferenceResults(data: data) {
                    result = inferenceResult
                    
                    saveTranslationRecord(braille: inferenceResult.braille, text: inferenceResult.text)
                } else {
                    print("sth wrong")
                }
            } else {
                print("cannot convert to png")
            }
            
        }
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .scaleEffect(scale)
                .offset(offset)
                
            if let result = result {
                resultsOverlay(result: result)
                    .allowsHitTesting(false)
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
    
    private func resultsOverlay(result: InferenceResult) -> some View {
        
        let text = result.text
        let boxSize = result.boundingBox.size
        
        return Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        Text(text)
                            .font(.system(size: calcFontSize(text: text, containerSize: boxSize)))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(nil)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .ignoresSafeArea()
                    .frame(width: boxSize.width, height: boxSize.height)
                    .position(
                        x: result.boundingBox.midX,
                        y: result.boundingBox.midY
                    )
                    .scaleEffect(scale)
                    .offset(offset)
    }
    
    private func calcFontSize(text: String, containerSize: CGSize) -> CGFloat {
        let charCount = text.count
        let boxArea = containerSize.width * containerSize.height
        
        return (boxArea / CGFloat(charCount)) * 0.3
    }
    
}


