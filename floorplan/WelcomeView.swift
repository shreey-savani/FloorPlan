import SwiftUI

struct WelcomeView: View {
    @State private var savedRoomIDs: [String] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Room Plan")
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
                    .padding()
            } else {
                ScrollView {
                    ForEach(savedRoomIDs, id: \.self) { id in
                        HStack {
                            Button(action: {
                                deleteRoom(id: id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        Divider()
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: loadSavedRooms)
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
        // Remove the ID from the list
        savedRoomIDs.removeAll { $0 == id }
        
        // Update UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(savedRoomIDs, forKey: "savedRoomIDs")
        
        // Optionally, remove the corresponding data from UserDefaults
        defaults.removeObject(forKey: id)
    }
}
