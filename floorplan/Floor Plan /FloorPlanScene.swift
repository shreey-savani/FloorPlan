// FloorPlanScene.swift
// floorplan

import RoomPlan
import SpriteKit

class FloorPlanScene: SKScene {
    
    // MARK: - Properties
    
    private let viewOption = true
    
    // Surfaces and objects from the scan result
    private let surfaces: [CapturedRoom.Surface]
    private let objects: [CapturedRoom.Object]
    private let capturedRoom: CapturedRoom
    
    // Buttons
    private var dismissButton: UIButton!
    private var saveButton: UIButton!
    private var loadButton: UIButton!
    
    // Camera variables
    private var previousCameraScale = CGFloat()
    private var previousCameraPosition = CGPoint()
    
    // MARK: - Init
    
    init(capturedRoom: CapturedRoom) {
        self.capturedRoom = capturedRoom
        self.surfaces = capturedRoom.doors + capturedRoom.openings + capturedRoom.walls + capturedRoom.windows
        self.objects = capturedRoom.objects
        
        super.init(size: CGSize(width: 1500, height: 1500))
        
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .lightGray
        
        addCamera()
        drawSurfaces()
        drawObjects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupPanGesture()
        setupPinchGesture()
      
    }
    
    // MARK: - Camera
    private func addCamera() {
        let cameraNode = SKCameraNode()
        addChild(cameraNode)
        self.camera = cameraNode
    }
    
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
    
    private func setupPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view?.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupPinchGesture() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(_:)))
        self.view?.addGestureRecognizer(pinchGestureRecognizer)
    }
    // MARK: - Touch Handling for Dragging Objects
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            // Check if the touched node is an SKSpriteNode and move it
            if let node = self.atPoint(previousLocation) as? SKSpriteNode {
                node.position = location
            }
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
}
