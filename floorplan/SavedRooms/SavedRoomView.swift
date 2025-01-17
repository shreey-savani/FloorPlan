import SwiftUI
import RoomPlan

struct SavedRoomView: View {
    let roomID: String
    @State private var capturedRoom: CapturedRoom?
    
    var body: some View {
        VStack {
            if let room = capturedRoom {
                Text("Floor Plan: \(roomID)")
                    .font(.title)
                    .padding()
                
                Text("Number of surfaces: \(room.doors.count + room.walls.count + room.windows.count + room.openings.count)")
                    .padding()
            } else {
                Text("Loading...")
            }
        }
        .onAppear(perform: loadRoom)
        .navigationTitle("Saved Room")
    }
    
    private func loadRoom() {
        print("loading in savedroom view")
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: roomID) {
            let decoder = JSONDecoder()
            do {
                capturedRoom = try decoder.decode(CapturedRoom.self, from: data)
            } catch {
                print("Error loading room: \(error)")
            }
        }
    }
}
