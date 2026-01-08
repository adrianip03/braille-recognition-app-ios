//
//  BrailleAppApp.swift
//  BrailleApp
//
//  Created by adrian on 3/1/2026.
//

import SwiftUI
import SwiftData

@main
struct BrailleAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TranslationRecord.self)
    }
}
