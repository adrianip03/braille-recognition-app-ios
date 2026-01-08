//
//  PreviewContainer.swift
//  BrailleApp
//
//  Created by adrian on 8/1/2026.
//

import SwiftData
import SwiftUI

struct TranlationRecordSampleData: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(for: TranslationRecord.self, configurations: .init(isStoredInMemoryOnly: true))
        TranslationRecord.sampleData.forEach{ container.mainContext.insert($0) }
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}


extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var translationRecordSampleData: Self = .modifier(TranlationRecordSampleData())
}
