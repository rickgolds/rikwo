import CoreML
import Vision
import UIKit

class RecognitionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognitionResult: String = ""
    @Published var history: [RecognitionRecord] = []
    @Published var showingCamera = false
    @Published var showingPhotoPicker = false
    @Published var errorMessage: String?
    
    private let maxHistoryCount = 10
    private let historyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("history.json")
    
    init() {
        loadHistory()
    }
    
    func recognizeObject(in image: UIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: .init()).model) else {
            errorMessage = "Nie zaladowano coreML"
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                self?.errorMessage = "Nie udalo sie rozpoznac"
                return
            }
            
            let resultText = "Objekt: \(topResult.identifier)\nPewność: \(Int(topResult.confidence * 100))%"
            self?.recognitionResult = resultText
            
            let record = RecognitionRecord(
                id: UUID(),
                image: image,
                result: resultText,
                date: Date()
            )
            
            DispatchQueue.main.async {
                self?.history.insert(record, at: 0)
                if self?.history.count ?? 0 > self?.maxHistoryCount ?? 10 {
                    self?.history.removeLast()
                }
                self?.saveHistory()
            }
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        guard let cgImage = image.cgImage else {
            errorMessage = "Zly obraz"
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    func saveHistory() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(history.map { HistoryEntry(record: $0) })
            try data.write(to: historyFileURL)
        } catch {
            print("Nie udalo sie zapiasc do historii: \(error)")
        }
    }
    
    func loadHistory() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let data = try Data(contentsOf: historyFileURL)
            let entries = try decoder.decode([HistoryEntry].self, from: data)
            history = entries.compactMap { $0.toRecord() }
        } catch {
            print("Nie udalo sie zaladowac historii: \(error)")
        }
    }
    
    func exportResult(_ record: RecognitionRecord) {
        let text = "Wynik analizy\nData: \(record.date.formatted())\n\(record.result)"
        let activityController = UIActivityViewController(activityItems: [text, record.image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true)
    }
}

struct HistoryEntry: Codable {
    let id: UUID
    let imageData: Data
    let result: String
    let date: Date
    
    init(record: RecognitionRecord) {
        self.id = record.id
        self.imageData = record.image.jpegData(compressionQuality: 0.8) ?? Data()
        self.result = record.result
        self.date = record.date
    }
    
    func toRecord() -> RecognitionRecord? {
        guard let image = UIImage(data: imageData) else { return nil }
        return RecognitionRecord(id: id, image: image, result: result, date: date)
    }
}
