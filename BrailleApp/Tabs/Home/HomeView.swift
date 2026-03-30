//
//  HomeView.swift
//  BrailleApp
//
//  Created by adrian on 3/1/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<TranslationRecord> { $0.bookmarked == true }, sort: \TranslationRecord.datetime, order: .reverse) private var bookmarkedRecords: [TranslationRecord]
    
    
    let onSeeBookmarks: () -> Void
    
    var body: some View {
        NavigationStack{
            ScrollView {
                
                VStack(spacing: 24) {
                    
                    VStack(spacing: 16) {
                        Text("Braille Translator")
                            .font(.largeTitle)
                        Text("Translate braille to text")
                            .font(.subheadline)
                    }
                    
                    // add quick actions
                    
                        
                    if !bookmarkedRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Bookmarks")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                Button(action: onSeeBookmarks) {
                                    Text("See All")
                                        .font(.subheadline)
                                }
                                
                            }
                            .padding(.horizontal)
                            
                            ForEach(bookmarkedRecords.prefix(3)) { record in
                                RecordCardView(record: record)
                                    .padding(.horizontal)
                            }
                        }
                        
                    }
                }
                
                
            }
            .navigationTitle(Text("Home"))
        }
    }

}

#Preview {
    HomeView(onSeeBookmarks: {})
}
