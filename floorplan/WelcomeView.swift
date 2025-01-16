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
                        NavigationLink(destination: SavedRoomView(roomID: id)) {
                            Text("Scan \(id)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
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
}
