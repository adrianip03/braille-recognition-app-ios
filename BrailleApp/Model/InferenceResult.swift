//
//  InferenceResult.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftData
import SwiftUI

@Model
class InferenceResult: Identifiable {
    var id: UUID
    var braille: String
    var text: String
    var confidence: Double
    var boundingBox: CGRect
    
    init(braille: String,
         text: String,
         confidence: Double,
         boundingBox: CGRect) {
        self.id = UUID()
        self.braille = braille
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}
