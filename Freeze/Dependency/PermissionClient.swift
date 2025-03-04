import AVFoundation
import Foundation
import Photos


struct PermissionClient {
    let updateCameraPermission: () async -> PermissionState
    let updateDiskPermission: () async -> PermissionState
}
extension PermissionClient {
    static let liveValue: PermissionClient = {
        let updateCameraPermission: () async -> PermissionState = {
            return await withCheckedContinuation { continuation in
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { isAuthorized in
                        continuation.resume(returning: isAuthorized ? .authorized : .denied)
                    }
                case .denied, .restricted:
                    continuation.resume(returning: .denied)
                case .authorized:
                    continuation.resume(returning: .authorized)
                @unknown default:
                    continuation.resume(returning: .denied)
                }
            }
        }
        
        let updateDiskPermission: () async -> PermissionState = {
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized, .limited:
                        continuation.resume(returning: .authorized)
                    case .denied, .restricted:
                        continuation.resume(returning: .denied)
                    case .notDetermined:
                        continuation.resume(returning: .authorized)
                    @unknown default:
                        continuation.resume(returning: .denied)
                    }
                }
            }
        }
        
        return Self(
            updateCameraPermission: updateCameraPermission,
            updateDiskPermission: updateDiskPermission
        )
    }()
}

enum PermissionState {
    case denied
    case notDetermined
    case authorized
}
