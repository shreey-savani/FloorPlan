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
                    if let previewURL = previewURL {
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
                SpriteKitView()
            }
        }
        .navigationTitle(roomID)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Load Preview URL
    private func loadPreviewURL() {
        let defaults = UserDefaults.standard
        if let filePath = defaults.string(forKey: roomID),
           let fileURL = URL(string: filePath) {
            previewURL = fileURL
            print(previewURL?.pathExtension ?? "No extension")
            if let previewURL = previewURL {
                print("Preview file exists: \(FileManager.default.fileExists(atPath: previewURL.path))")
                print("Preview URL: \(previewURL)")
            }
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
    var body: some View {
        SpriteKitContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct SpriteKitContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = SKScene(size: CGSize(width: 400, height: 400))
        scene.backgroundColor = .blue // Customize the background
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Update your SpriteKit view if necessary
    }
}
