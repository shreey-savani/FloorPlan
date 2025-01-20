import Foundation
import SpriteKit
import RoomPlan
import SwiftUI

protocol FloorPlanSceneDelegate: AnyObject {
    func navigateToWelcomeView()
}

class FloorPlanScene: SKScene {
    
    // MARK: - Properties
    
    private let is3DViewEnabled = true
    private let capturedSurfaces: [CapturedRoom.Surface]
    private let capturedObjects: [CapturedRoom.Object]
    private let roomData: CapturedRoom
    
    private var roomCaptureModel: RoomCaptureModel?
    
    weak var sceneDelegate: FloorPlanSceneDelegate?
    
    private var dismissButton: UIButton!
    private var saveButton: UIButton!

    private var initialCameraScale: CGFloat = 1.0
    private var initialCameraPosition: CGPoint = .zero
    
    // MARK: - Initializer
    
    init(capturedRoom: CapturedRoom, roomCaptureModel: RoomCaptureModel?) {
        self.roomData = capturedRoom
        self.capturedSurfaces = capturedRoom.doors + capturedRoom.openings + capturedRoom.walls + capturedRoom.windows
        self.capturedObjects = capturedRoom.objects
        self.roomCaptureModel = roomCaptureModel
        super.init(size: CGSize(width: 1500, height: 1500))
        
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .lightGray
        
        setupCamera()
        setupDismissButton()
        renderSurfaces()
        renderObjects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        configurePanGesture()
        configurePinchGesture()
        let directoryURL = RoomCaptureModel.shared.roomDirectoryURL 

        saveSceneAsSKN(to: directoryURL!)
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        let cameraNode = SKCameraNode()
        addChild(cameraNode)
        self.camera = cameraNode
    }
    
    private func configurePanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view?.addGestureRecognizer(panGesture)
    }
    
    private func configurePinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.view?.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Dismiss Button Setup
    
    private func setupDismissButton() {
        dismissButton = UIButton(type: .system)
        styleDismissButton()
        
        guard let view = self.view else { return }
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 200),
            dismissButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func styleDismissButton() {
        dismissButton.setTitle("Back to Welcome", for: .normal)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.backgroundColor = .blue
        dismissButton.layer.cornerRadius = 8
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(dismissScene), for: .touchUpInside)
    }
    
    @objc private func dismissScene() {
        sceneDelegate?.navigateToWelcomeView()
    }
    
    // MARK: - Pan Gesture Handler
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let camera = self.camera else { return }
        if gesture.state == .began {
            initialCameraPosition = camera.position
        }
        
        let translationScale = camera.xScale
        let translation = gesture.translation(in: self.view)
        let newCameraPosition = CGPoint(
            x: initialCameraPosition.x - translation.x * translationScale,
            y: initialCameraPosition.y + translation.y * translationScale
        )
        camera.position = newCameraPosition
    }
    
    // MARK: - Pinch Gesture Handler
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let camera = self.camera else { return }
        if gesture.state == .began {
            initialCameraScale = camera.xScale
        }
        
        let newScale = initialCameraScale / gesture.scale
        camera.setScale(clamp(value: newScale, lower: 0.5, upper: 5.0)) // Limits zoom levels
    }
    
    private func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return max(lower, min(value, upper))
    }
    
    // MARK: - Render Surfaces and Objects
    
    private func renderSurfaces() {
        for surface in capturedSurfaces {
            let surfaceNode = FloorPlanSurface(capturedSurface: surface)
            addChild(surfaceNode)
        }
    }
    
    private func renderObjects() {
        for object in capturedObjects {
            let objectNode = FloorPlanObject(capturedRoom: roomData, capturedObject: object)
            addChild(objectNode)
        }
    }
    
    // MARK: - Save SKN File
    
    func saveSceneAsSKN(to directory: URL) {
        let sknFileURL = directory.appendingPathComponent("FloorPlanScene.skn")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try data.write(to: sknFileURL)
            print("Scene successfully saved to \(sknFileURL.path)")
        } catch {
            print("Failed to save scene: \(error)")
        }
    }
}
