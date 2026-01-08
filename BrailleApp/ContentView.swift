//
//  ContentView.swift
//  BrailleApp
//
//  Created by adrian on 3/1/2026.
//

import SwiftUI

enum Tabs {
    case home
    case history
    case bookmarks
    case camera
}

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeView()
            }
            Tab("Bookmarks", systemImage: "bookmark", value: .bookmarks) {
                BookmarkView()
            }
            Tab("History", systemImage: "clock", value: .history) {
                HistoryView()
            }
            Tab("Camera", systemImage: "camera", value: .camera, role: .search) {
                NavigationStack{
                    CameraView(
                        onExit: {
                            selectedTab = .home
                        })
    //                    .edgesIgnoringSafeArea(.all)
                        .toolbar(.hidden, for: .tabBar)
                }
                
            }
            
        }
    }
    
}

#Preview {
    ContentView()
}
