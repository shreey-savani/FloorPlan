import Foundation
import RoomPlan

class RoomCaptureModel: NSObject, RoomCaptureSessionDelegate {
    
    // Singleton
    static let shared = RoomCaptureModel()
    
    // The capture view
    let roomCaptureView: RoomCaptureView
    
    // Capture and room builder configuration
    private let captureSessionConfig: RoomCaptureSession.Configuration
    private let roomBuilder: RoomBuilder
    
    // The final scan result
    var finalRoom: RoomPlan.CapturedRoom?
    
    // Private initializer. Accessed by shared.
    private override init() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        
        super.init()
        roomCaptureView.captureSession.delegate = self
    }
        
    // Start and stop the capture session. Available from our RoomCaptureScanView.
    func startSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
    
    
    
    
    // Create the final scan result: a CapturedRoom object
    func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {
        if let error {
            print("Error ending capture session; \(error)")
        }
        
        Task {
            finalRoom = try! await roomBuilder.capturedRoom(from: data)
        }
    }
    
    // MARK: - Save Captured Room
    private func saveCapturedRoom(_ room: CapturedRoom) {
        let encoder = JSONEncoder()
        do {
            let roomID = "Room\(Date().timeIntervalSince1970)"
            let roomData = try encoder.encode(room)
            
            // Save room data to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(roomData, forKey: roomID)
            
            var savedRoomIDs = defaults.array(forKey: "savedRoomIDs") as? [String] ?? []
            savedRoomIDs.append(roomID)
            defaults.set(savedRoomIDs, forKey: "savedRoomIDs")
            
            print("Room saved with ID: \(roomID)")
            
            // Get directory for UserDefaults
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                let debugDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
                    .appendingPathComponent("Preferences")
                    .appendingPathComponent("\(bundleIdentifier).plist")
                
                print("Debug: UserDefaults data stored in directory: \(debugDirectory.path)")
            }
        } catch {
            print("Error saving captured room: \(error)")
        }
}

    
    
}
