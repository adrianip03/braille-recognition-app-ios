//
//  InferenceResult.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftData
import SwiftUI

// bounding boxes are normalized
struct APIResponse: Codable {
    let braille: String
    let text: String
    let confidence: Double
    let message: String?
    let boundingBox: [CGFloat]?
    let inpaintedImage: ImageResponse?
}

struct ImageResponse: Codable {
    let mimeType: String
    let encoding: String
    let data: String // b64
}

struct InferenceResult {
    var braille: String
    var text: String
    var confidence: Double
    var boundingBox: CGRect
    
    init(from response: APIResponse, imageSize: CGSize) {
        self.braille = response.braille
        self.text = response.text
        self.confidence = response.confidence
        
        if let bbox = response.boundingBox, bbox.count == 4 {
            self.boundingBox = CGRect(
                x: bbox[0],
                y: bbox[1],
                width: bbox[2],
                height: bbox[3]
            )
        } else {
            self.boundingBox = CGRect(
                x: 0.25,
                y: 0.24,
                width: 0.5,
                height: 0.25
            )
        }
    }
}
