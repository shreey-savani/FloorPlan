import Foundation
import RoomPlan
import QuickLook

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
    
    // Start and stop the capture session
    func startSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
    
    // Handle session end and generate the final captured room
    func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {
        if let error = error {
            print("Error ending capture session: \(error)")
            return
        }
        
        Task {
            do {
                finalRoom = try await roomBuilder.capturedRoom(from: data)
                print("Room successfully captured.")
                
                // Generate a unique ID and save the captured room
                let uniqueID = UUID().uuidString
                saveCapturedRoom(with: uniqueID)
                
            } catch {
                print("Failed to process captured room data: \(error)")
            }
        }
    }
    
    // Save the captured room as a .usdz file
    func saveCapturedRoom(with id: String) {
        guard let finalRoom = finalRoom else {
            print("No captured room data available to save.")
            return
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(id).usdz")
        
        do {
            try finalRoom.export(to: fileURL)
            
            // Save the ID and file path in UserDefaults
            let defaults = UserDefaults.standard
            var savedIDs = defaults.array(forKey: "savedRoomIDs") as? [String] ?? []
            if !savedIDs.contains(id) {
                savedIDs.append(id)
            }
            defaults.set(savedIDs, forKey: "savedRoomIDs")
            defaults.set(fileURL.absoluteString, forKey: id)
            
            print("Captured room data successfully saved to \(fileURL.path)")
        } catch {
            print("Failed to save captured room data: \(error)")
        }
    }
}
