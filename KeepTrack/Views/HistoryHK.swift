//
//  HistoryHK.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 5/5/25.
//

import SwiftUI
import OSLog
import HealthKit

struct HistoryHK: View {
    
    let dateFormatter = DateFormatter()
    
    var dataTypeIdentifier: String
    var dataValues: [HealthDataTypeValue] = []
    
    public var showGroupedTableViewTitle: Bool = false
    
    private var emptyDataView: EmptyDataBackground {
        return EmptyDataBackground(message: "No Data")
    }
    
    init(dataTypeIdentifier: String) {
        self.dataTypeIdentifier = dataTypeIdentifier
        dateFormatter.dateStyle = .medium
    }
    var body: some View {
        Text("Hello Z")
        
        self.dataValues.isEmpty ? self.emptyDataView : self.emptyDataView
    }
}

#Preview {
    HistoryHK(dataTypeIdentifier: "Water")
}
