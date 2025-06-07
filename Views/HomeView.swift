//
//  HomeView.swift
//  Recon
//
//  Created by Gracek on 12/05/2025.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @ObservedObject var viewModel: RecognitionViewModel
    @State private var showingResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Text("Wybierz lub zrób zdjęcie")
                        .foregroundColor(.gray)
                        .frame(height: 300)
                }
                
                Button("Zrób zdjęcie") {
                    viewModel.showingCamera = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Wybierz z galerii") {
                    viewModel.showingPhotoPicker = true
                }
                .buttonStyle(.bordered)
                
                if !viewModel.recognitionResult.isEmpty {
                    Button("Pokaż wynik") {
                        showingResult = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                
                if viewModel.selectedImage != nil || !viewModel.recognitionResult.isEmpty {
                    Button("Wyczyść") {
                        viewModel.selectedImage = nil
                        viewModel.recognitionResult = ""
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Rozpoznawanie obiektów")
            .sheet(isPresented: $viewModel.showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $viewModel.selectedImage)
                    .onDisappear {
                        if let image = viewModel.selectedImage {
                            viewModel.recognizeObject(in: image)
                        }
                    }
            }
            .sheet(isPresented: $viewModel.showingPhotoPicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.selectedImage)
                    .onDisappear {
                        if let image = viewModel.selectedImage {
                            viewModel.recognizeObject(in: image)
                        }
                    }
            }
            .sheet(isPresented: $showingResult) {
                ResultView(result: viewModel.recognitionResult)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: RecognitionViewModel())
}
