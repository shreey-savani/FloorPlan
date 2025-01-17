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
        setupSaveButton()
        setupLoadButton()
        setupDismissButton()
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
    
    // MARK: - Save and Load Buttons
    
    private func setupSaveButton() {
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped(_:)), for: .touchUpInside)
        
        let screenWidth = self.view?.frame.size.width ?? 0
        saveButton.frame = CGRect(x: 20, y: 50, width: 100, height: 40)
        self.view?.addSubview(saveButton)
    }
    
    @objc private func onSaveButtonTapped(_ sender: UIButton) {
        saveScene()
    }
    
    private func setupLoadButton() {
        loadButton = UIButton(type: .system)
        loadButton.setTitle("Load", for: .normal)
        loadButton.addTarget(self, action: #selector(onLoadButtonTapped(_:)), for: .touchUpInside)
        
        let screenWidth = self.view?.frame.size.width ?? 0
        loadButton.frame = CGRect(x: 130, y: 50, width: 100, height: 40)
        self.view?.addSubview(loadButton)
    }
    
    @objc private func onLoadButtonTapped(_ sender: UIButton) {
        loadScene()
    }
    
    private func setupDismissButton() {
        dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(onDismissButtonTapped(_:)), for: .touchUpInside)
        
        let screenWidth = self.view?.frame.size.width ?? 0
        dismissButton.frame = CGRect(x: screenWidth - 120, y: 50, width: 100, height: 40)
        self.view?.addSubview(dismissButton)
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIButton) {
        self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Save Scene
    
    func saveScene() {
        var objectDataArray: [SceneData.ObjectData] = []
        
        for child in self.children {
            if let spriteNode = child as? SKSpriteNode {
                let objectData = SceneData.ObjectData(
                    id: UUID().uuidString,
                    type: String(describing: type(of: spriteNode)),
                    position: spriteNode.position,
                    size: spriteNode.size,
                    color: spriteNode.color.hexString
                )
                objectDataArray.append(objectData)
            }
        }
        
        let sceneData = SceneData(objects: objectDataArray)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(sceneData) {
            let fileURL = getDocumentsDirectory().appendingPathComponent("SceneData.json")
            try? data.write(to: fileURL)
            print("Scene saved to \(fileURL)")
        }
    }
    
    // MARK: - Load Scene
    
    func loadScene() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("SceneData.json")
        guard let data = try? Data(contentsOf: fileURL) else {
            print("No saved scene data found.")
            return
        }
        
        let decoder = JSONDecoder()
        if let sceneData = try? decoder.decode(SceneData.self, from: data) {
            self.removeAllChildren()
            for object in sceneData.objects {
                let color = UIColor(hex: object.color) ?? .white
                let node = SKSpriteNode(color: color, size: object.size)
                node.position = object.position
                node.name = object.id
                addChild(node)
            }
            print("Scene loaded successfully.")
        }
    }
    
 
    
    
           // MARK: - Save and Load Scene Data
        
        func loadFromSceneData(_ sceneData: SceneData) {
            // Clear current scene
            self.removeAllChildren()
            
            // Add objects from scene data
            for object in sceneData.objects {
                let color = UIColor(hex: object.color) ?? .white
                let node = SKSpriteNode(color: color, size: object.size)
                node.position = object.position
                node.name = object.id
                addChild(node)
            }
        }
        
        func exportSceneData() -> SceneData {
            var objectDataArray: [SceneData.ObjectData] = []
            
            for child in self.children {
                if let spriteNode = child as? SKSpriteNode {
                    let objectData = SceneData.ObjectData(
                        id: spriteNode.name ?? UUID().uuidString,
                        type: String(describing: type(of: spriteNode)),
                        position: spriteNode.position,
                        size: spriteNode.size,
                        color: spriteNode.color.hexString
                    )
                    objectDataArray.append(objectData)
                }
            }
            
            return SceneData(objects: objectDataArray)
        }


    
    // MARK: - Utility
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
