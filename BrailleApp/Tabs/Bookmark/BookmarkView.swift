//
//  BookmarkView.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftUI
import SwiftData

struct BookmarkView: View {
    @Query(filter: #Predicate<TranslationRecord> { $0.bookmarked == true }, sort: \TranslationRecord.datetime, order: .reverse) private var bookmarkedRecords: [TranslationRecord]
    
    var body: some View {
        NavigationStack{
            List(bookmarkedRecords) { record in
                RecordCardView(record: record)
            }
            .navigationTitle(Text("Bookmarks"))
        }
    }
        

    }

    #Preview {
        BookmarkView()
    }
