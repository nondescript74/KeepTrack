//
//  HelpSystemDemo.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 11/14/25.
//

import SwiftUI

/// A demo view showing how to use the help system in your views
struct HelpSystemDemo: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Demo View")
                    .font(.largeTitle)
                
                Text("This is an example of how to add help to any view.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Tap the '?' button in the top-right corner to see the help content.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Add Help to Your Views:")
                        .font(.headline)
                    
                    Text("1. Add '.helpButton(for: .yourView)' to any view")
                        .font(.caption)
                    Text("2. Define help content in HelpContent.swift")
                        .font(.caption)
                    Text("3. Add your view identifier to HelpViewIdentifier enum")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Help System")
            // This is how you add help to any view!
            .helpButton(for: .dashboard)
        }
    }
}

#Preview {
    HelpSystemDemo()
}
