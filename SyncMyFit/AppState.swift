//
//  AppState.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-07-08.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func checkLoginState() {
        if FitbitAuthManager.shared.storedAccessToken != nil {
            if FitbitAuthManager.shared.isTokenValid() {
                isLoggedIn = true
            } else {
                FitbitAuthManager.shared.refreshAccessToken { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self.isLoggedIn = true
                        case .failure:
                            self.logout()
                        }
                    }
                }
            }
        } else {
            isLoggedIn = false
        }
    }

    func logout() {
        FitbitAuthManager.shared.logout()
        isLoggedIn = false
    }

    func loginSuccessful() {
        isLoggedIn = true
    }
}
