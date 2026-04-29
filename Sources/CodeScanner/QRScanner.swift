//
//  QRScanner.swift
//  CodeScanner
//
//  Created by saucym on 2026/1/8.
//

#if os(iOS)
import AVFoundation
import SwiftUI
import PhotosUI

public struct QRScanner: View {
    let done: (String) async -> Bool
    public init(done: @escaping (String) async -> Bool) {
        self.done = done
    }
    @State private var selectedItem: PhotosPickerItem? = nil
    @Environment(\.presentationMode) var presentationMode
    public var body: some View {
        CodeScannerView(codeTypes: [.qr], showViewfinder: true) { response in
            if case let .success(result) = response, let text = result.texts.first {
                Task { @MainActor in
                    let dismiss = await done(text.string)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 26))
                        .padding(60)
                }
                Spacer()
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 26))
                        .padding(60)
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // 识别图片中的二维码
                    recognizeQRCode(in: image)
                }
            }
        }
    }
    
    func recognizeQRCode(in image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage)
        
        if let qrFeature = features?.first as? CIQRCodeFeature, let text = qrFeature.messageString {
            Task { @MainActor in
                let dismiss = await done(text)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#endif
