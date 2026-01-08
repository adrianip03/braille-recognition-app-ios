//
//  RecordDetailView.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftUI
import SwiftData

struct RecordDetailView: View {
    let record: TranslationRecord
    
    @State private var sourceText: String = ""
    @State private var translatedText: String = ""
    var body: some View {
        List {
            Section(header: Text("Translated text")) {
                Text(translatedText)
                    .font(record.direction == .textToBraille ?
                        .custom("Braille-Regular", size: 16, relativeTo: .body) :
                        .callout)
            }
            
            Section(header: Text("Source text")) {
                Text(sourceText)
                    .font(record.direction == .textToBraille ?
                        .callout:
                        .custom("Braille-Regular", size: 16, relativeTo: .body) )
            }
        }
        .onAppear {
            if record.direction == .textToBraille {
                sourceText = record.text
                translatedText = record.braille
            } else {
                sourceText = record.braille
                translatedText = record.text
            }
        }
    }
}

#Preview (traits: .translationRecordSampleData) {
    @Previewable @Query(sort: \TranslationRecord.datetime, order: .reverse) var records: [TranslationRecord]
    RecordDetailView(record: records[0])
}
