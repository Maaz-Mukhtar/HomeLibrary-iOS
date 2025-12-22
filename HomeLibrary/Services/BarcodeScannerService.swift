//
//  BarcodeScannerService.swift
//  HomeLibrary
//
//  Created by Claude Code
//

import AVFoundation
import UIKit

/// Service for scanning barcodes using AVFoundation
class BarcodeScannerService: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var isScanning = false
    @Published var error: ScannerError?

    let captureSession = AVCaptureSession()
    private var hasScanned = false

    override init() {
        super.init()
    }

    func setupSession() throws {
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw ScannerError.noCamera
        }

        let input = try AVCaptureDeviceInput(device: device)

        guard captureSession.canAddInput(input) else {
            throw ScannerError.cannotAddInput
        }
        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(output) else {
            throw ScannerError.cannotAddOutput
        }
        captureSession.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [
            .ean13,
            .ean8,
            .upce,
            .code128
        ]
    }

    func startScanning() {
        guard !captureSession.isRunning else { return }
        hasScanned = false
        scannedCode = nil
        error = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        isScanning = true
    }

    func stopScanning() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isScanning = false
    }

    func resetScanner() {
        hasScanned = false
        scannedCode = nil
        error = nil
    }

    private func validateISBN(_ code: String) -> Bool {
        let digits = code.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        return digits.count == 10 || digits.count == 13
    }

    func toggleFlash() throws {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            return
        }

        try device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue else {
            return
        }

        // Validate it's a valid ISBN
        guard validateISBN(code) else {
            return
        }

        hasScanned = true
        stopScanning()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        scannedCode = code
    }
}

// MARK: - Scanner Errors

enum ScannerError: LocalizedError {
    case noCamera
    case cannotAddInput
    case cannotAddOutput
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noCamera: return "No camera available"
        case .cannotAddInput: return "Cannot access camera input"
        case .cannotAddOutput: return "Cannot configure scanner output"
        case .permissionDenied: return "Camera permission denied"
        }
    }
}
