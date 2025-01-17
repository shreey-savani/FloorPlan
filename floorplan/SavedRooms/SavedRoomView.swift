import SwiftUI
import SpriteKit

struct SavedRoomView: View {
    let roomID: String
    @State private var scene: FloorPlanScene? // SpriteKit scene
    @State private var isSceneLoaded = false
    
    var body: some View {
        VStack {
            if isSceneLoaded, let scene = scene {
                Text("Floor Plan: \(roomID)")
                    .font(.title)
                    .padding()
                
                // Render the SpriteKit scene using SpriteView
                SpriteView(scene: scene)
                    .frame(width: 300, height: 300)
                    .border(Color.gray, width: 2)
                    .padding()
                
                // Save button to save changes
                Button(action: {
                    saveSceneChanges()
                }) {
                    Text("Save Changes")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            } else {
                Text("Loading...")
                    .padding()
            }
        }
        .onAppear(perform: loadScene)
        .navigationTitle("Saved Room")
    }
    
    private func loadScene() {
        print("Loading saved room: \(roomID)")
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(roomID).json")
        guard let data = try? Data(contentsOf: fileURL) else {
            print("No saved scene data found for \(roomID).")
            return
        }
        
        let decoder = JSONDecoder()
        if let sceneData = try? decoder.decode(SceneData.self, from: data) {
            // Create a new SpriteKit scene from the data
            let floorPlanScene = FloorPlanScene(size: CGSize(width: 300, height: 300))
            floorPlanScene.loadFromSceneData(sceneData) // Custom method to load data
            self.scene = floorPlanScene
            self.isSceneLoaded = true
        } else {
            print("Failed to decode scene data.")
        }
    }
    
    private func saveSceneChanges() {
        guard let scene = scene else { return }
        
        // Extract the updated scene data
        let sceneData = scene.exportSceneData()
        
        // Save the updated data as JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(roomID).json")
        
        if let data = try? encoder.encode(sceneData) {
            try? data.write(to: fileURL)
            print("Scene changes saved to \(fileURL).")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
