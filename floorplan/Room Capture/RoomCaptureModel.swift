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
    var floorPlanScene: FloorPlanScene?
    // Room directory URL accessible externally
    var roomDirectoryURL: URL?
    
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
                if let roomDirectoryURL = saveCapturedRoom(with: uniqueID) {
                    // Here, we do not save an additional file anymore
                    print("Captured room directory URL: \(roomDirectoryURL.path)")
                    self.roomDirectoryURL = roomDirectoryURL // Expose the room directory URL
                }
                
            } catch {
                print("Failed to process captured room data: \(error)")
            }
        }
    }
    
    // Save the captured room as a .usdz file in a UUID-based directory
    // Save the captured room as a .usdz and .skn file in a UUID-based directory
    func saveCapturedRoom(with id: String) -> URL? {
        guard let finalRoom = finalRoom else {
            print("No captured room data available to save.")
            return nil
        }
        
        // Access the shared directory
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            print("Shared directory is unavailable.")
            return nil
        }
        
        // Create a subdirectory for this capture using the UUID
        let roomDirectoryURL = sharedDirectoryURL.appendingPathComponent(id)
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: roomDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: roomDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Created room directory at \(roomDirectoryURL.path)")
            } catch {
                print("Failed to create room directory: \(error)")
                return nil
            }
        }
        
        // File URL for the .usdz file
        let usdzFileURL = roomDirectoryURL.appendingPathComponent("room.usdz")
        let sknFileURL = roomDirectoryURL.appendingPathComponent("FloorPlanScene.skn")
        
        do {
            // Save the .usdz file
            try finalRoom.export(to: usdzFileURL)
            print("Captured room data successfully saved to \(usdzFileURL.path)")
            
            // Save the .skn file (assuming you have a `FloorPlanScene` object to save)
            if let floorPlanScene = self.floorPlanScene {  // You should pass the `FloorPlanScene` instance somehow
                let data = try NSKeyedArchiver.archivedData(withRootObject: floorPlanScene, requiringSecureCoding: false)
                try data.write(to: sknFileURL)
                print("Scene successfully saved to \(sknFileURL.path)")
            }
            
            // Save the ID and directory path in UserDefaults
            let defaults = UserDefaults.standard
            var savedIDs = defaults.array(forKey: "savedRoomIDs") as? [String] ?? []
            if !savedIDs.contains(id) {
                savedIDs.append(id)
            }
            defaults.set(savedIDs, forKey: "savedRoomIDs")
            defaults.set(roomDirectoryURL.absoluteString, forKey: id)
            
        } catch {
            print("Failed to save captured room data: \(error)")
        }
        
        // Return the directory URL to be used for any further use
        return roomDirectoryURL
    }

    // Get the shared directory URL for saving rooms
    static func getSharedDirectoryURL() -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sharedDirectoryURL = documentsURL.appendingPathComponent("CapturedRooms")
        
        if !fileManager.fileExists(atPath: sharedDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: sharedDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Created shared directory at \(sharedDirectoryURL.path)")
            } catch {
                print("Failed to create shared directory: \(error)")
                return nil
            }
        }
        
        return sharedDirectoryURL
    }
}
