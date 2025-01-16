// FloorPlanScene.swift
// floorplan

import RoomPlan
import SpriteKit

class FloorPlanScene: SKScene {
    
    // MARK: - Properties
    
    private let viewOption = true
    
    // Surfaces and objects from our scan result
    private let surfaces: [CapturedRoom.Surface]
    private let objects: [CapturedRoom.Object]
    private let capturedRoom: CapturedRoom
    
    // MARK: - Init
    
    init(capturedRoom: CapturedRoom) {
        self.capturedRoom = capturedRoom
        self.surfaces = capturedRoom.doors + capturedRoom.openings + capturedRoom.walls + capturedRoom.windows
        self.objects = capturedRoom.objects
        
        super.init(size: CGSize(width: 1500, height: 1500))
        
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = floorPlanBackgroundColor
        
        addCamera()
        drawSurfaces()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        pinchGestureRecognizer.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        setupSaveButton()
        setupDismissButton()
    }
    
    // MARK: - Setup Dismiss Button
    private var dismissButton: UIButton!
    
    private func setupDismissButton() {
        dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(onDismissButtonTapped(_:)), for: .touchUpInside)
        
        let screenWidth = self.view?.frame.size.width ?? 0
        dismissButton.frame = CGRect(x: screenWidth - 170, y: 20, width: 150, height: 50)
        self.view?.addSubview(dismissButton)
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIButton) {
        self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Save Button
    private var saveButton: UIButton!
    
    private func setupSaveButton() {
        print("save 2")
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped(_:)), for: .touchUpInside)
        
        let screenWidth = self.view?.frame.size.width ?? 0
        saveButton.frame = CGRect(x: (screenWidth - 150) / 2, y: 20, width: 150, height: 50)
        self.view?.addSubview(saveButton)
        print("save 3")
    }
    
    @objc private func onSaveButtonTapped(_ sender: UIButton) {
        saveRoomData()
        print("save 1")
    }
    
    // MARK: - Save Room Data
    private func saveRoomData() {
        print("save 4")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self.capturedRoom)
            UserDefaults.standard.set(data, forKey: "savedRoomData")
            showAlert(title: "Success", message: "Room data saved successfully!")
        } catch {
            showAlert(title: "Error", message: "Failed to save room data: \(error)")
        }
        print("save 4")
    }
    
    // MARK: - Draw
    private func drawSurfaces() {
        for surface in surfaces {
            let surfaceNode = FloorPlanSurface(capturedSurface: surface)
            addChild(surfaceNode)
        }
    }
    
    private func drawObjects() {
        for object in objects {
            let objectNode = FloorPlanObject(capturedRoom: capturedRoom, capturedObject: object)
            addChild(objectNode)
        }
    }
    
    // MARK: - Camera
    private func addCamera() {
        let cameraNode = SKCameraNode()
        addChild(cameraNode)
        self.camera = cameraNode
    }
    
    // Variables to store camera scale and position during gestures
    private var previousCameraScale = CGFloat()
    private var previousCameraPosition = CGPoint()
    
    // Pan gesture for camera movement
    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        guard let camera = self.camera else { return }
        if sender.state == .began {
            previousCameraPosition = camera.position
        }
        let translationScale = camera.xScale
        let panTranslation = sender.translation(in: self.view)
        let newCameraPosition = CGPoint(
            x: previousCameraPosition.x + panTranslation.x * -translationScale,
            y: previousCameraPosition.y + panTranslation.y * translationScale
        )
        camera.position = newCameraPosition
    }
    
    // Pinch gesture for zoom
    @objc private func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = self.camera else { return }
        if sender.state == .began {
            previousCameraScale = camera.xScale
        }
        camera.setScale(previousCameraScale * 1 / sender.scale)
    }
    
    // MARK: - Helper: Show Alert
    private func showAlert(title: String, message: String) {
        guard let viewController = self.view?.window?.rootViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
