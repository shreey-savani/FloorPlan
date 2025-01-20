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
    private var captureDirectory: URL?
    
    // The final scan result
    var finalRoom: RoomPlan.CapturedRoom?
    var floorPlanScene: FloorPlanScene?
    // Room directory URL accessible externally
    var roomDirectoryURL: URL?
    
    // Private initializer
    private override init() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        
        super.init()
        roomCaptureView.captureSession.delegate = self
    }
    
    // Start the capture session
    func startSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    // Stop the capture session
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
                // Build the captured room from the data
                finalRoom = try await roomBuilder.capturedRoom(from: data)
                print("Room successfully captured.")
                
                // Save the .usdz file
                let uniqueID = UUID().uuidString
                if let directoryURL = saveUSDZFile(with: uniqueID) {
                    print("Captured room directory URL: \(directoryURL.path)")
                    self.roomDirectoryURL = directoryURL // Expose the room directory URL for the next step
                }
            } catch {
                print("Failed to process captured room data: \(error)")
            }
        }
    }
    
    // Save the .usdz file in a UUID-based directory
    private func saveUSDZFile(with id: String) -> URL? {
        guard let finalRoom = finalRoom else {
            print("No captured room data available to save.")
            return nil
        }
        
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            print("Shared directory is unavailable.")
            return nil
        }
        
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
        
        let usdzFileURL = roomDirectoryURL.appendingPathComponent("room.usdz")
        
        do {
            try finalRoom.export(to: usdzFileURL)
            print("Captured room data successfully saved to \(usdzFileURL.path)")
            
            // Save the directory path to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(roomDirectoryURL.absoluteString, forKey: id)
        } catch {
            print("Failed to save captured room data: \(error)")
        }
        
        return roomDirectoryURL
    }
    
    // Save the .skn file in the directory created earlier
//    func saveSKNFile(floorPlanScene: FloorPlanScene) {
//        guard let roomDirectoryURL = self.roomDirectoryURL else {
//            print("Error: Room directory URL is unavailable.")
//            return
//        }
//        
//        let sknFileURL = roomDirectoryURL.appendingPathComponent("FloorPlanScene.skn")
//        
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: floorPlanScene, requiringSecureCoding: false)
//            try data.write(to: sknFileURL)
//            print("Scene successfully saved to \(sknFileURL.path)")
//        } catch {
//            print("Failed to save .skn file: \(error)")
//        }
//    }
    
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
