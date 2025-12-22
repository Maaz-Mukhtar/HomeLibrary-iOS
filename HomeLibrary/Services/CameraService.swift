//
//  CameraService.swift
//  HomeLibrary
//
//  Created by Claude Code
//

import AVFoundation
import SwiftUI

/// Service for handling camera permissions
@MainActor
class CameraService: ObservableObject {
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined

    init() {
        checkPermission()
    }

    func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        checkPermission()
        return granted
    }

    var isAuthorized: Bool {
        permissionStatus == .authorized
    }

    var isDenied: Bool {
        permissionStatus == .denied || permissionStatus == .restricted
    }

    var needsRequest: Bool {
        permissionStatus == .notDetermined
    }
}
