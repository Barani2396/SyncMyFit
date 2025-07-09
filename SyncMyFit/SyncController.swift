//
//  SyncController.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-06-30.
//

import Foundation

class SyncController {
    static let shared = SyncController()

    func fetchUserProfile(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = FitbitAuthManager.shared.accessToken else {
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }

        let url = URL(string: "https://api.fitbit.com/1/user/-/profile.json")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1)))
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = (json["user"] as? [String: Any]),
                   let name = user["displayName"] as? String {
                    completion(.success(name))
                } else {
                    completion(.failure(NSError(domain: "Unexpected response", code: -2)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func syncAllData(completion: @escaping (Result<Void, Error>) -> Void) {
            // Fetch from Fitbit, write to HealthKit
            // Call fetchTodaySteps, fetchHeartRate, fetchSleepData etc. internally
        }
    
    func fetchTodaySteps(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let token = FitbitAuthManager.shared.accessToken else {
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }

        let date = ISO8601DateFormatter().string(from: Date()).prefix(10) // yyyy-MM-dd
        let url = URL(string: "https://api.fitbit.com/1/user/-/activities/date/\(date).json")!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let summary = json["summary"] as? [String: Any],
                   let steps = summary["steps"] as? Int {
                    completion(.success(steps))
                } else {
                    completion(.failure(NSError(domain: "Unexpected response", code: -2)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func fetchHeartRateData() { /* Coming soon */ }
    
    func fetchSleepData() { /* Coming soon */ }

    func writeStepsToHealthKit(steps: Int) { /* Already handled or can be added */ }
}
