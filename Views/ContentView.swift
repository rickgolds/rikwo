//
//  ContentView.swift
//  Recon
//
//  Created by Gracek on 12/05/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecognitionViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem { Label("Strona główna", systemImage: "house") }
            HistoryView(viewModel: viewModel)
                .tabItem { Label("Historia", systemImage: "clock") }
        }
    }
}

#Preview {
    ContentView()
}
