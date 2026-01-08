//
//  RecordCardView.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftUI

struct RecordCardView: View {
    let record: TranslationRecord

    @State private var sourceText: String = ""
    @State private var translatedText: String = ""
    @Environment(\.modelContext) private var context
    @State private var showDetails: Bool = false
    
    var body: some View {
        ZStack {
            
            Button {
                showDetails = true
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(translatedText)
                            .font(record.direction == .textToBraille ?
                                .custom("Braille-Regular", size: 18, relativeTo: .body) :
                                .headline)
                            .lineLimit(2)
                        
                        Text(sourceText)
                            .font(record.direction == .textToBraille ?
                                .subheadline :
                                .custom("Braille-Regular", size: 16, relativeTo: .body))
                            .lineLimit(2)
                    }
                    
                    
                    Spacer()

                }
                .onAppear {
                    if record.direction == .brailleToText {
                        sourceText = record.braille
                        translatedText = record.text
                    } else {
                        sourceText = record.text
                        translatedText = record.braille
                    }
                }
                .padding(.trailing, 16)
            }
            .buttonStyle(.plain)
//            .contentShape(Rectangle())
            .sheet(isPresented: $showDetails) {
                NavigationStack {
                    RecordDetailView(record: record)
    //                    .toolbar {
    //                        ToolbarItem(placement: .topBarTrailing) {
    //                            Button("Done") {
    //                                showDetails = false
    //                            }
    //                        }
    //                    }
                    
                }
            }
            
            HStack {
                Spacer()
                
                Button (action: {
                    record.bookmarked.toggle()
                    try? context.save()
                }) {
                    if record.bookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "bookmark")
                            .foregroundColor(.text)
                    }
                }
//                .contentShape(Rectangle())
//                .allowsHitTesting(false)
            }
        }
        
        
        
    }
}

#Preview {
    let previewRecord = TranslationRecord.sampleData[1]
    NavigationStack {
        RecordCardView(record: previewRecord)
    }
}
