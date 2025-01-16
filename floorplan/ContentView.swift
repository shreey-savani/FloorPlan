//  ContentView.swift
//  floorplan
//
//  Created by teqnodux on 13/01/25.

import SwiftUI
import _SpriteKit_SwiftUI

struct ContentView: View {
    @State private var isShowingFloorPlan = false

    var body: some View {
        ZStack {
            RoomCaptureRepresentable()
                .ignoresSafeArea()
        }
        .onAppear {
            startSession()
        }
        .fullScreenCover(isPresented: $isShowingFloorPlan) {
            if let finalRoom = RoomCaptureModel.shared.finalRoom {
                SpriteView(scene: FloorPlanScene(capturedRoom: finalRoom))
                    .ignoresSafeArea()
            }
        }
        Button(isScanning ? "Done" : "View 2D floor plan") {
            if isScanning {
                stopSession()
            } else {
                isShowingFloorPlan = true
            }
        }
    }

    @State private var isScanning = false

    private func startSession() {
        isScanning = true
        RoomCaptureModel.shared.startSession()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func stopSession() {
        isScanning = false
        RoomCaptureModel.shared.stopSession()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

#Preview {
    ContentView()
}
