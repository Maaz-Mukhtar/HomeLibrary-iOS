//
//  BarcodeScannerView.swift
//  HomeLibrary
//
//  Created by Claude Code
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraService = CameraService()
    @StateObject private var scannerService = BarcodeScannerService()

    @State private var isFlashOn = false
    @State private var showingResult = false
    @State private var lookupResult: BookAPIService.BookLookupResult?
    @State private var isLoading = false
    @State private var errorMessage: String?

    let onBookFound: (BookAPIService.BookLookupResult) -> Void

    var body: some View {
        ZStack {
            // Camera Preview
            if cameraService.isAuthorized {
                CameraPreviewView(session: scannerService.captureSession)
                    .ignoresSafeArea()

                // Scanning Overlay
                scanningOverlay
            } else if cameraService.isDenied {
                permissionDeniedView
            } else {
                requestingPermissionView
            }

            // Loading Overlay
            if isLoading {
                loadingOverlay
            }

            // Top Bar
            VStack {
                topBar
                Spacer()
            }
        }
        .onAppear {
            setupScanner()
        }
        .onDisappear {
            scannerService.stopScanning()
        }
        .onChange(of: scannerService.scannedCode) { _, code in
            if let code = code {
                lookupBook(isbn: code)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("Try Again") {
                errorMessage = nil
                scannerService.resetScanner()
                scannerService.startScanning()
            }
            Button("Enter Manually") {
                dismiss()
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showingResult) {
            if let result = lookupResult {
                ScanResultView(result: result) { confirmed in
                    if confirmed {
                        onBookFound(result)
                        dismiss()
                    } else {
                        // Try again
                        showingResult = false
                        lookupResult = nil
                        scannerService.resetScanner()
                        scannerService.startScanning()
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                toggleFlash()
            } label: {
                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title2)
                    .foregroundStyle(isFlashOn ? .yellow : .white)
                    .padding(12)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
        .padding(.top, 40)
    }

    private var scanningOverlay: some View {
        VStack {
            Spacer()

            // Scanning guide frame
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 280, height: 150)
                .overlay {
                    // Corner accents
                    GeometryReader { geo in
                        let cornerLength: CGFloat = 30
                        let lineWidth: CGFloat = 4

                        // Top left
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: cornerLength))
                            path.addLine(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: cornerLength, y: 0))
                        }
                        .stroke(Color.primaryBlue, lineWidth: lineWidth)

                        // Top right
                        Path { path in
                            path.move(to: CGPoint(x: geo.size.width - cornerLength, y: 0))
                            path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                            path.addLine(to: CGPoint(x: geo.size.width, y: cornerLength))
                        }
                        .stroke(Color.primaryBlue, lineWidth: lineWidth)

                        // Bottom left
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geo.size.height - cornerLength))
                            path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                            path.addLine(to: CGPoint(x: cornerLength, y: geo.size.height))
                        }
                        .stroke(Color.primaryBlue, lineWidth: lineWidth)

                        // Bottom right
                        Path { path in
                            path.move(to: CGPoint(x: geo.size.width - cornerLength, y: geo.size.height))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - cornerLength))
                        }
                        .stroke(Color.primaryBlue, lineWidth: lineWidth)
                    }
                }

            Text("Position barcode within the frame")
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.top, 20)

            Spacer()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Looking up book...")
                    .foregroundStyle(.white)
                    .font(.headline)
            }
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Please enable camera access in Settings to scan barcodes.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Cancel") {
                dismiss()
            }
            .foregroundStyle(.secondary)
        }
    }

    private var requestingPermissionView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Requesting camera access...")
                .foregroundStyle(.secondary)
        }
        .task {
            _ = await cameraService.requestPermission()
            if cameraService.isAuthorized {
                setupScanner()
            }
        }
    }

    // MARK: - Methods

    private func setupScanner() {
        guard cameraService.isAuthorized else { return }

        do {
            try scannerService.setupSession()
            scannerService.startScanning()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleFlash() {
        do {
            try scannerService.toggleFlash()
            isFlashOn.toggle()
        } catch {
            // Flash not available
        }
    }

    private func lookupBook(isbn: String) {
        isLoading = true

        Task {
            do {
                let apiService = BookAPIService()
                let result = try await apiService.lookupByISBN(isbn)
                await MainActor.run {
                    isLoading = false
                    lookupResult = result
                    showingResult = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Could not find book information for this ISBN. Would you like to try again or enter the details manually?"
                }
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            guard let session = session else { return }
            previewLayer.session = session
        }
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
    }
}

// MARK: - Scan Result View

struct ScanResultView: View {
    let result: BookAPIService.BookLookupResult
    let onDecision: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Cover Image (pre-downloaded for instant display)
                    if let imageData = result.coverImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .cornerRadius(Constants.CornerRadius.medium)
                    } else if let urlString = result.coverImageURL,
                              let url = URL(string: urlString) {
                        // Fallback to AsyncImage if pre-download failed
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .frame(height: 250)
                        .cornerRadius(Constants.CornerRadius.medium)
                    }

                    // Book Info
                    VStack(spacing: 12) {
                        Text(result.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        if !result.authors.isEmpty {
                            Text(result.authors.joined(separator: ", "))
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if let genre = result.genre {
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.primaryBlue.opacity(0.1))
                                .foregroundStyle(Color.primaryBlue)
                                .cornerRadius(Constants.CornerRadius.small)
                        }

                        if let isbn = result.isbn {
                            Text("ISBN: \(isbn)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            onDecision(true)
                        } label: {
                            Text("Add This Book")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryBlue)
                                .foregroundStyle(.white)
                                .cornerRadius(Constants.CornerRadius.medium)
                        }

                        Button {
                            onDecision(false)
                        } label: {
                            Text("Not the right book? Scan again")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Book Found")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
