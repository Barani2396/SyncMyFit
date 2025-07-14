//
//  Color+AppColors.swif.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-07-13.
//

import SwiftUI

/// Color extensions for app-wide usage.
/// These rely on color definitions from the Assets.xcassets folder.
extension Color {
    
    // MARK: - Global Theme Colors
    
    /// Primary color used for foregrounds and titles
    static let syncPrimary = Color("AppPrimary")
    
    /// Destructive color used for buttons like "Sign Out"
    static let syncDestructive = Color("AppDestructive")
    
    /// Background color for overall screens
    static let syncBackground = Color("AppBackground")
    
    /// Accent color for highlights and secondary actions
    static let syncAccent = Color("AccentColor")
    
    // MARK: - Health Metric Colors
    
    /// Color for Sleep metrics
    static let metricSleep = Color("MetricColorSleep")
    
    /// Color for Heart Rate metrics
    static let metricHeartRate = Color("MetricColorHeartRate")
    
    /// Color for Step Count metrics
    static let metricSteps = Color("MetricColorSteps")
    
    /// Color for Calories metrics
    static let metricCalories = Color("MetricColorCalories")
}
