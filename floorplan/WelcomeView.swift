import SwiftUICore
import SwiftUI

struct WelcomeView: View {
    @State private var savedDirectories: [String] = []
    @State private var selectedRoomID: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Room Plan")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    NavigationLink(destination: RoomCaptureScanView()) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()

                Divider()

                // Saved rooms
                if savedDirectories.isEmpty {
                    Text("No saved scans")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(savedDirectories, id: \.self) { directory in
                            HStack {
                                NavigationLink(
                                    destination: ModelDetailView(roomID: directory)
                                ) {
                                    Text("Room ID: \(directory)")
                                        .font(.headline)
                                        .padding(.leading)
                                }
                                Spacer()

                                Button(action: {
                                    deleteDirectory(directory)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing)
                            }
                            .padding()
                            .background(Color(UIColor.systemGroupedBackground))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                    }
                    .padding()
                }
            }
            .onAppear(perform: loadSavedDirectories)
        }
    }

    private func loadSavedDirectories() {
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            savedDirectories = []
            return
        }

        do {
            let fileManager = FileManager.default
            let directories = try fileManager.contentsOfDirectory(atPath: sharedDirectoryURL.path)
                .filter { directoryName in
                    var isDirectory: ObjCBool = false
                    let path = sharedDirectoryURL.appendingPathComponent(directoryName).path
                    return fileManager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
                }
            savedDirectories = directories
        } catch {
            print("Failed to load saved directories: \(error)")
            savedDirectories = []
        }
    }

    private func deleteDirectory(_ directory: String) {
        guard let sharedDirectoryURL = RoomCaptureModel.getSharedDirectoryURL() else {
            return
        }

        let directoryPath = sharedDirectoryURL.appendingPathComponent(directory).path

        do {
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: directoryPath)
            // Remove the directory from the list
            savedDirectories.removeAll { $0 == directory }
        } catch {
            print("Failed to delete directory: \(error)")
        }
    }
}

