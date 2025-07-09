//
//  SyncMyFitApp.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-06-24.
//

import SwiftUI
import AuthenticationServices

@main
struct SyncMyFitApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if appState.isLoggedIn {
                    DashboardView()
                        .environmentObject(appState)
                } else {
                    LoginView()
                        .environmentObject(appState)
                }
            }
            .onAppear {
                appState.checkLoginState()
            }
            .onOpenURL { url in
                FitbitAuthManager.shared.handleRedirectURL(url)
            }
        }
    }
}

