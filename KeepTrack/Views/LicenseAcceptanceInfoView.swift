//
//  LicenseAcceptanceInfoView.swift
//  KeepTrack
//
//  Created on 11/14/25.
//

import SwiftUI

/// A view that displays license acceptance information
/// Can be used in Settings or About screens
struct LicenseAcceptanceInfoView: View {
    let licenseManager: LicenseManager
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("License Agreement")
                            .font(.headline)
                        
                        if let version = licenseManager.acceptedVersion {
                            Text("Accepted Version: \(version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Not yet accepted")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Spacer()
                    
                    if licenseManager.hasAcceptedCurrentVersion {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.title2)
                    }
                }
                
                if let date = licenseManager.acceptedDate {
                    Divider()
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Acceptance Date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(date, style: .date)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Acceptance Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(date, style: .time)
                                .font(.subheadline)
                        }
                    }
                }
                
                if let info = licenseManager.acceptanceInfo {
                    Divider()
                    
                    Text(info)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !licenseManager.hasAcceptedCurrentVersion && licenseManager.acceptedVersion != nil {
                    Divider()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.orange)
                        
                        Text("New version requires license acceptance")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        } label: {
            Label("License Status", systemImage: "doc.text")
                .font(.headline)
        }
    }
}

#Preview("Accepted Current Version") {
    VStack {
        let manager = LicenseManager()
        let _ = manager.acceptLicense()
        
        LicenseAcceptanceInfoView(licenseManager: manager)
            .padding()
    }
}

#Preview("Not Accepted") {
    VStack {
        let manager = LicenseManager()
        
        LicenseAcceptanceInfoView(licenseManager: manager)
            .padding()
    }
}

#Preview("Old Version Accepted") {
    let userDefaults = UserDefaults(suiteName: "preview")!
    userDefaults.set("1.0", forKey: "AcceptedLicenseVersion")
    userDefaults.set(Date().addingTimeInterval(-86400 * 30), forKey: "AcceptedLicenseDate")
    
    let manager = LicenseManager(userDefaults: userDefaults)
    
    return VStack {
        LicenseAcceptanceInfoView(licenseManager: manager)
            .padding()
    }
}
