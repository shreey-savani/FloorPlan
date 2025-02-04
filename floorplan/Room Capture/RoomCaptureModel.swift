import Foundation
import RoomPlan
import simd

// Custom structure to represent a wall (start, end, length)
struct Wall {
    var start: SIMD3<Float>
    var end: SIMD3<Float>
    var length: Float
    var category: CapturedRoom.Surface.Category // Added category for additional context
}

class RoomCaptureModel: NSObject, RoomCaptureSessionDelegate {
    
    static let shared = RoomCaptureModel()
    
    let roomCaptureView: RoomCaptureView
    private let captureSessionConfig: RoomCaptureSession.Configuration
    private let roomBuilder: RoomBuilder
    private var captureDirectory: URL?
    
    var finalRoom: CapturedRoom?
    var roomDirectoryURL: URL?
    
    // Store the walls' data
    var walls: [Wall] = [] // Array to store wall data
    
    private override init() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        
        super.init()
        roomCaptureView.captureSession.delegate = self
    }
    
    func startSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
    
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
                
                // Extract and process wall data
                extractWallData()
                
                // Optionally save the .usdz file
                let uniqueID = UUID().uuidString
                if let directoryURL = saveUSDZFile(with: uniqueID) {
                    print("Captured room directory URL: \(directoryURL.path)")
                    self.roomDirectoryURL = directoryURL
                }
            } catch {
                print("Failed to process captured room data: \(error)")
            }
        }
    }
    
    // Extract wall data from the captured room
    private func extractWallData() {
        guard let capturedRoom = finalRoom else {
            print("No captured room data available.")
            return
        }

        // Loop through the room's surfaces (which represent walls)
        for (index, surface) in capturedRoom.walls.enumerated() {
            print("Surface \(index) - Category: \(surface.category)")  // Debug surface category
            print("Surface \(index) - Full Surface Data: \(surface)")  // Debug full surface object

            if surface.category == .wall {
                let boundary = surface.polygonCorners // Access polygon corners
                print("Surface \(index) - Boundary points: \(boundary)")  // Debug the boundary points

                if boundary.count > 1 {
                    let start = boundary.first!
                    let end = boundary.last!
                    let length = distanceBetween(start: start, end: end)

                    print("Surface \(index) - Start point: \(start), End point: \(end)")
                    print("Surface \(index) - Calculated wall length: \(length) meters")

                    let wall = Wall(start: start, end: end, length: length, category: surface.category)
                    walls.append(wall)

                    print("Wall \(index) from \(start) to \(end) with length \(length) meters, Category: \(surface.category)")
                } else {
                    print("Surface \(index) does not have enough points to form a valid wall.")
                }
            } else {
                print("Surface \(index) is not a wall, skipping.")
            }
        }

        print("Total number of walls captured: \(walls.count)")
        if walls.isEmpty {
            print("No valid walls were extracted.")
        } else {
            for (index, wall) in walls.enumerated() {
                print("Wall \(index) - Start: \(wall.start), End: \(wall.end), Length: \(wall.length), Category: \(wall.category)")
            }
        }
    }
    // Helper function to calculate distance between two points (SIMD3<Float>)
    private func distanceBetween(start: SIMD3<Float>, end: SIMD3<Float>) -> Float {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        return sqrt(dx * dx + dy * dy + dz * dz)
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
