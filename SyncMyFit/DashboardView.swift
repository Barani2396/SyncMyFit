//
//  DashboardView.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-06-30.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var steps: Int?
    @State private var userName: String?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Menu {
                    Button("Log out", role: .destructive) {
                        appState.logout()
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                }
            }

            if let name = userName {
                 Text("👋 Welcome, \(name)!")
                     .font(.headline)
            }
            
            Text("Dashboard")
                .font(.largeTitle)
                .bold()
        
            if let steps = steps {
                Text("Steps today: \(steps)").font(.title2)
            } else if let error = errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            } else {
                Text("Tap the button to sync your steps.")
                    .foregroundStyle(.gray)
            }

            Button("Sync Steps") {
                SyncController.shared.fetchTodaySteps { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedSteps):
                            steps = fetchedSteps
                            errorMessage = nil
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            steps = nil
                        }
                    }
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    DashboardView()
}
