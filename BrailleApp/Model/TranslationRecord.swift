//
//  TranslationRecord.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import Foundation
import SwiftData

@Model
class TranslationRecord: Identifiable, Hashable {
    var id: UUID
    var braille: String
    var text: String
    var direction: Direction
    var datetime: Date
    var bookmarked: Bool
    
    enum Direction: String, Codable {
        case brailleToText
        case textToBraille
    }
    
    init(braille: String,
         text: String,
         direction: Direction) {
        self.id = UUID()
        self.datetime = Date()
        self.braille = braille
        self.text = text
        self.direction = direction
        self.bookmarked = false
    }
    
}


extension TranslationRecord {
    static let sampleData: [TranslationRecord] =
    [
        TranslationRecord(
            braille: ",lorem ipsum dolor sit amet1 consectetur adipiscing elit4 ,nulla ex tortor1 cursus nec lacinia vel1 convallis quis neque4 ,nunc id fringilla justo1 et faucibus dui4 ,suspendisse vel dignissim nulla1 sed fermentum nunc4 ,donec varius ornare nisl1 ;a dignissim enim aliquam quis4 ,cras diam tortor1 pharetra quis tempor sit amet1 dictum quis mauris4 test fullstop . ",
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ex tortor, cursus nec lacinia vel, convallis quis neque. Nunc id fringilla justo, et faucibus dui. Suspendisse vel dignissim nulla, sed fermentum nunc. Donec varius ornare nisl, a dignissim enim aliquam quis. Cras diam tortor, pharetra quis tempor sit amet, dictum quis mauris. ",
            direction: .brailleToText),
        
            TranslationRecord(
                braille: ",lorem ipsum dolor sit amet1 consectetur adipiscing elit4 ,nulla ex tortor1 cursus nec lacinia vel1 convallis quis neque4 ,nunc id fringilla justo1 et faucibus dui4 ,suspendisse vel dignissim nulla1 sed fermentum nunc4 ,donec varius ornare nisl1 ;a dignissim enim aliquam quis4 ,cras diam tortor1 pharetra quis tempor sit amet1 dictum quis mauris4 test fullstop . ",
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ex tortor, cursus nec lacinia vel, convallis quis neque. Nunc id fringilla justo, et faucibus dui. Suspendisse vel dignissim nulla, sed fermentum nunc. Donec varius ornare nisl, a dignissim enim aliquam quis. Cras diam tortor, pharetra quis tempor sit amet, dictum quis mauris. ",
                direction: .textToBraille)
    ]
}
