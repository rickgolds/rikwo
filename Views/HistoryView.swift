//
//  HistoryView.swift
//  Recon
//
//  Created by Gracek on 12/05/2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: RecognitionViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.history) { record in
                    VStack(alignment: .leading) {
                        Image(uiImage: record.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Text(record.result)
                            .font(.caption)
                        Text(record.date.formatted())
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Button("Eksportuj") {
                            viewModel.exportResult(record)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Historia")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        viewModel.history.remove(atOffsets: offsets)
        viewModel.saveHistory() 
    }
}

#Preview {
    HistoryView(viewModel: RecognitionViewModel())
}
