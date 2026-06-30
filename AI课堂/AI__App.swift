//
//  AI__App.swift
//  AI课堂
//
//  Created by LazyG on 2026/6/26.
//

import SwiftUI

@main
struct AI__App: App {
    @StateObject private var appState = AppState.live

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
                .preferredColorScheme(AppTheme.preferredColorScheme)
                .tint(AppColors.primaryAction)
        }
    }
}
