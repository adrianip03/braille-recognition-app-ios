//
//  HistoryView.swift
//  BrailleApp
//
//  Created by adrian on 7/1/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \TranslationRecord.datetime, order: .reverse) private var records: [TranslationRecord]
    
    var body: some View {
        NavigationStack{
            List(records) { record in
                RecordCardView(record: record)
            }
            //            .accessibilityLabel(category.name)
            //        .scrollDismissesKeyboard(.interactively)
            .navigationTitle(Text("History"))
        }
    }
    
}

#Preview(traits: .translationRecordSampleData) {
    HistoryView()
}
