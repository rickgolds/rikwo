//
//  RecognitionRecord.swift
//  Recon
//
//  Created by Gracek on 12/05/2025.
//

import UIKit

struct RecognitionRecord: Identifiable {
    let id: UUID
    let image: UIImage
    let result: String
    let date: Date
}
