//
//  LoginView.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-06-30.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.red)

            Text("SyncMyFit").font(.largeTitle).bold()

            Text("Sync your Fitbit data with Apple Health")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.horizontal)

            Button("Sign in with Fitbit") {
                startLoginFlow()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func startLoginFlow() {
        FitbitAuthManager.shared.startLogin { result in
            switch result {
            case .success(let code):
                FitbitAuthManager.shared.fetchAccessToken(authCode: code) { tokenResult in
                    switch tokenResult {
                    case .success:
                        DispatchQueue.main.async {
                            appState.loginSuccessful()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            showError = true
                            errorMessage = "Token fetch failed: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showError = true
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
