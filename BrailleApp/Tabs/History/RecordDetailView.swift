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
    @State private var showingCopyAlert = false
    @State private var copiedText = ""
    
    var body: some View {
        List {
            Section(header: Text("Translated text")) {
                VStack (alignment: .leading) {
                    Text(translatedText)
                        .font(record.direction == .textToBraille ?
                            .custom("Braille-Regular", size: 16, relativeTo: .body) :
                            .callout)
                    HStack {
                        Spacer()
                        Button(action: {
                            copyToClipboard(translatedText)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
            }
            
            Section(header: Text("Source text")) {
                VStack (alignment: .leading) {
                    Text(sourceText)
                        .font(record.direction == .textToBraille ?
                            .callout:
                            .custom("Braille-Regular", size: 16, relativeTo: .body) )
                        .onLongPressGesture(minimumDuration: 0.5) {
                            copyToClipboard(sourceText)
                        }
                    HStack {
                        Spacer()
                        Button(action: {
                            copyToClipboard(translatedText)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
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
        .alert("Copied!", isPresented: $showingCopyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("'\(copiedText)' has been copied to clipboard")
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        copiedText = text.count > 50 ? String(text.prefix(50)) + "..." : text
//        showingCopyAlert = true
    }
    
}

#Preview (traits: .translationRecordSampleData) {
    @Previewable @Query(sort: \TranslationRecord.datetime, order: .reverse) var records: [TranslationRecord]
    RecordDetailView(record: records[0])
}
