//
//  ScannerView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI
import VisionKit
import AVFoundation
import Vision

struct CustomDataScannerViewController: UIViewControllerRepresentable {
    let recognizedDataTypes: Set<VNBarcodeSymbology>
    let qualityLevel: AVCaptureSession.Preset
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean8, .ean13, .pdf417, .qr, .code128, .code39, .code93, .upce])],
            qualityLevel: .accurate,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCodeScanned: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let firstBarcode = items.first else { return }
            if case .barcode(let barcode) = firstBarcode {
                onCodeScanned(barcode.payloadStringValue ?? "")
            }
        }
    }
}

struct ScannerView: View {
    @ObservedObject var viewModel: BookViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scannedISBN: String?
    @State private var isScanning = true
    @State private var scanningStatus = "Ready to scan"
    
    var body: some View {
        ZStack {
            CustomDataScannerViewController(
                recognizedDataTypes: [.ean13],
                qualityLevel: .high,
                onCodeScanned: { isbn in
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    scannedISBN = isbn
                    isScanning = false
                    scanningStatus = "Found barcode: \(isbn)"
                    fetchBookDetails(isbn: isbn)
                }
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text(scanningStatus)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
            
            if !isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
            }
        }
    }
    
    private func fetchBookDetails(isbn: String) {
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        
        guard let url = URL(string: urlString) else {
            scanningStatus = "Invalid ISBN format"
            isScanning = true
            return
        }
        
        scanningStatus = "Fetching book details..."
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    scanningStatus = "Network error: \(error.localizedDescription)"
                    isScanning = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    scanningStatus = "No data received"
                    isScanning = true
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(GoogleBooksAPIResponse.self, from: data)
                guard let bookItem = result.items?.first else {
                    DispatchQueue.main.async {
                        scanningStatus = "Book not found in database"
                        isScanning = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    scanningStatus = "Found book! Adding to library..."
                    
                    // Enhanced price retrieval
                    var price: Double? = nil
                    
                    if let saleInfo = bookItem.saleInfo {
                        price = saleInfo.retailPrice?.amount ?? saleInfo.listPrice?.amount
                    }
                    
                    let newBook = Book(
                        title: bookItem.volumeInfo.title,
                        author: bookItem.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown",
                        description: bookItem.volumeInfo.description ?? "No description available",
                        coverImage: nil,
                        status: .library,
                        price: price
                    )
                    
                    viewModel.addBook(newBook)
                    
                    // Image fetching logic
                    if let imageUrlString = bookItem.volumeInfo.imageLinks?.thumbnail {
                        let largeImageUrlString = imageUrlString
                            .replacingOccurrences(of: "zoom=1", with: "zoom=3")
                            .replacingOccurrences(of: "thumbnail", with: "extraLarge")
                            .replacingOccurrences(of: "http:", with: "https:")
                        
                        let imageUrls: [String] = [
                            largeImageUrlString,
                            imageUrlString.replacingOccurrences(of: "http:", with: "https:"),
                            imageUrlString
                        ]
                        
                        for urlString in imageUrls {
                            guard let finalImageUrl = URL(string: urlString) else { continue }
                            
                            URLSession.shared.dataTask(with: finalImageUrl) { imageData, response, error in
                                if let imageData = imageData, UIImage(data: imageData) != nil {
                                    DispatchQueue.main.async {
                                        let updatedBook = Book(
                                            id: newBook.id,
                                            title: newBook.title,
                                            author: newBook.author,
                                            description: newBook.description,
                                            coverImage: imageData,
                                            status: newBook.status,
                                            dateAdded: newBook.dateAdded,
                                            price: price
                                        )
                                        
                                        viewModel.updateBook(updatedBook)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    return
                                }
                            }.resume()
                        }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    scanningStatus = "Error processing book data: \(error.localizedDescription)"
                    isScanning = true
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        ScannerView(viewModel: BookViewModel())
            .preferredColorScheme(.dark)
    }
}









