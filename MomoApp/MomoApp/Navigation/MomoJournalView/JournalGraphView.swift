//
//  JournalGraphView.swift
//  MomoApp
//
//  Created by Priscilla Ip on 2020-12-01.
//

import SwiftUI

// MARK: - JournalGraphView

struct JournalGraphView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel = EntriesViewModel(dataManager: MockDataManager())
    
    var body: some View {
        VStack(spacing: 48) {
            MiniGraphView(
                entries: self.viewModel.latestEntries,
                dataPoints: self.viewModel.dataPoints,
                onEntrySelected: self.viewModel.changeSelectedIdx(to:))
            MiniBlobView(
                blobValue: self.$viewModel.selectedEntry.value,
                entry: self.viewModel.selectedEntry)
        }
    }
}
