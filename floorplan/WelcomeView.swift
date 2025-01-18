import SwiftUI

struct WelcomeView: View {
    @State private var savedRoomIDs: [String] = []

    var body: some View {
        NavigationView {
            VStack {
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

                if savedRoomIDs.isEmpty {
                    Text("No saved scans")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(savedRoomIDs, id: \.self) { id in
                            NavigationLink(
                                destination: ModelDetailView(roomID: id),
                                label: {
                                    HStack {
                                        Text(id)
                                            .font(.headline)
                                            .padding(.leading)

                                        Spacer()

                                        Button(action: {
                                            deleteRoom(id: id)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .padding(.trailing)
                                    }
                                    .padding()
                                }
                            )
                            Divider()
                        }
                    }
                    .padding()
                }
            }
            .onAppear(perform: loadSavedRooms)
        }
    }

    // MARK: - Load Saved Room IDs
    private func loadSavedRooms() {
        let defaults = UserDefaults.standard
        if let savedIDs = defaults.array(forKey: "savedRoomIDs") as? [String] {
            savedRoomIDs = savedIDs
        }
    }

    // MARK: - Delete Room
    private func deleteRoom(id: String) {
        savedRoomIDs.removeAll { $0 == id }
        
        let defaults = UserDefaults.standard
        defaults.set(savedRoomIDs, forKey: "savedRoomIDs")
        
        if let filePath = defaults.string(forKey: id) {
            try? FileManager.default.removeItem(atPath: filePath)
            defaults.removeObject(forKey: id)
        }
    }
}
