import Foundation
import SwiftUI
import QuickLook
import SpriteKit

struct ModelDetailView: View {
    let roomID: String
    @State private var previewURL: URL? = nil
    @State private var selectedView: ViewType = .quickLook

    enum ViewType: String, CaseIterable, Identifiable {
        case quickLook = "3D"
        case spriteKit = "2D"
        
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack {
            Picker("View Type", selection: $selectedView) {
                ForEach(ViewType.allCases) { viewType in
                    Text(viewType.rawValue).tag(viewType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selectedView {
            case .quickLook:
                VStack {
                    if let previewURL = previewURL, FileManager.default.fileExists(atPath: previewURL.path) {
                        QuickLookPreview(url: previewURL)
                    } else {
                        Text("Loading model...")
                            .onAppear(perform: loadPreviewURL)
                    }
                    
                    Button(action: reloadPreview) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reload")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            case .spriteKit:
                SpriteKitView(roomID: roomID)
            }
        }
        .navigationTitle(roomID)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Load Preview URL
    private func loadPreviewURL() {
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            print("Shared directory not found.")
            return
        }

        let directoryURL = sharedDirectoryURL.appendingPathComponent(roomID)
        let fileURL = directoryURL.appendingPathComponent("room.usdz")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            previewURL = fileURL
            print("Preview file loaded successfully: \(fileURL)")
        } else {
            print("room.usdz file not found at \(fileURL.path)")
        }
    }

    // MARK: - Reload Preview
    private func reloadPreview() {
        previewURL = nil // Clear the current preview
        loadPreviewURL() // Reload the preview URL
    }
}

// MARK: - Quick Look Preview
struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        return previewController
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }
    }
}

// MARK: - SpriteKit View
struct SpriteKitView: View {
    let roomID: String
    
    var body: some View {
        SpriteKitContainer(roomID: roomID)
            .edgesIgnoringSafeArea(.all)
    }
}

struct SpriteKitContainer: UIViewRepresentable {
    let roomID: String

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        // Set debugging options for FPS and Node count
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Get the directory for the saved room and load the .skn file
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            print("Shared directory not found.")
            return skView
        }
        
        let roomDirectoryURL = sharedDirectoryURL.appendingPathComponent(roomID)
        let sknFileURL = roomDirectoryURL.appendingPathComponent("FloorPlanScene.sks")
        print("Checking .skn file path: \(sknFileURL.path)")
        
        if FileManager.default.fileExists(atPath: sknFileURL.path) {
            // Load the SKScene from the saved .skn file
            if let scene = loadScene(from: sknFileURL) {
                scene.scaleMode = .aspectFill // Set scale mode to aspectFill for proper rendering
                skView.presentScene(scene)
            } else {
                print("Failed to load the SKScene from .sks file.")
            }
        } else {
            print("File does not exist at \(sknFileURL.path)")
        }
        
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {}

    private func loadScene(from url: URL) -> SKScene? {
        do {
            let data = try Data(contentsOf: url)
            
            // Using the new unarchiving method for iOS 12 and above
            if let scene = try NSKeyedUnarchiver.unarchivedObject(ofClass: SKScene.self, from: data) {
                return scene
            } else {
                print("Failed to unarchive SKScene from data")
                return nil
            }
        } catch {
            print("Failed to load scene from .sks file: \(error)")
            return nil
        }
    }
}
