//
//  ResultView.swift
//  Recon
//
//  Created by Gracek on 12/05/2025.
//

import SwiftUI

struct ResultView: View {
    let result: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Wynik rozpoznania")
                .font(.headline)
                .padding()
            
            Text(result)
                .padding()
            
            Button("Zamknij") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

#Preview {
    ResultView(result: "Objekt: Cat\nPewność: 95%")
}
