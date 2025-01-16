////
////  em.swift
////  floorplan
////
////  Created by teqnodux on 15/01/25.
////
//
//```swift
//  private func getLargestSurface() {
//    largestSurface = surfaces.first
//    for surface in surfaces {
//      if surface.dimensions.x > largestSurface?.dimensions.x ?? 0 {
//        largestSurface = surface
//      }
//    }
//  }
//```
//
//here do the extra rotations for each wall.
//
//I also added a basic dimension calculator to demonstrate how this might look converting from the RoomPlan dimensions. This is not super useful in its current state but I was just playing around and figured I would share my findings.
//```
////
////  FloorPlanSurface.swift
////  RoomPlan 2D
////
////  Created by Dennis van Oosten on 12/03/2023.
////
//
//import SpriteKit
//import RoomPlan
//
//class FloorPlanSurface: SKNode {
//  
//  private let capturedSurface: CapturedRoom.Surface
//  
//  // MARK: - Computed properties
//  
//  private var halfLength: CGFloat {
//    return CGFloat(capturedSurface.dimensions.x) * scalingFactor / 2
//  }
//  
//  private var pointA: CGPoint {
//    return CGPoint(x: -halfLength, y: 0)
//  }
//  
//  private var pointB: CGPoint {
//    return CGPoint(x: halfLength, y: 0)
//  }
//  
//  private var pointADim: CGPoint {
//    return CGPoint(x: -halfLength, y: -dimensionLineDistFromSurface)
//  }
//  
//  private var pointBDim: CGPoint {
//    return CGPoint(x: halfLength, y: -dimensionLineDistFromSurface)
//  }
//  
//  private var pointC: CGPoint {
//    return pointB.rotateAround(point: pointA, by: 0.25 * .pi)
//  }
//  
//  // MARK: - Init
//  
//  init(capturedSurface: CapturedRoom.Surface) {
//    self.capturedSurface = capturedSurface
//    
//    super.init()
//    
//    // Set the surface's position using the transform matrix
//    let surfacePositionX = -CGFloat(capturedSurface.transform.position.x) * scalingFactor
//    let surfacePositionY = CGFloat(capturedSurface.transform.position.z) * scalingFactor
//    self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
//      .rotateAround(
//        point: CGPointZero,
//        by: -CGFloat(largestSurface?.transform.eulerAngles.y ?? 0)
//      ) //this rotation will rotate each point around an arbitrary point to get the roration of midpoints in the correct location
//    
//    // Set the surface's zRotation using the transform matrix
//    // the additional largest surface rotation here will get the new angle offset for each wall. i.e. if this is the largest wall the rotation will be 0 - largest wall rotation + largest wall rotation. this essentially brings it back to a horizontal angle.
//    self.zRotation = -CGFloat(capturedSurface.transform.eulerAngles.z - capturedSurface.transform.eulerAngles.y + (largestSurface?.transform.eulerAngles.y ?? 0))
//    
//    // Draw the right surface
//    switch capturedSurface.category {
//    case .door:
//      drawDoor()
//    case .opening:
//      drawOpening()
//    case .wall:
//      drawWall()
//    case .window:
//      drawWindow()
//    @unknown default:
//      drawWall()
//    }
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  // MARK: - Draw
//  
//  private func drawDoor() {
//    let hideWallPath = createPath(from: pointA, to: pointB)
//    let doorPath = createPath(from: pointA, to: pointC)
//    
//    // Hide the wall underneath the door
//    let hideWallShape = createShapeNode(from: hideWallPath)
//    hideWallShape.strokeColor = floorPlanBackgroundColor
//    hideWallShape.lineWidth = hideSurfaceWith
//    hideWallShape.zPosition = hideSurfaceZPosition
//    
//    // The door itself
//    let doorShape = createShapeNode(from: doorPath)
//    doorShape.lineCap = .round
//    doorShape.zPosition = doorZPosition
//    
//    // The door's arc
//    let doorArcPath = CGMutablePath()
//    doorArcPath.addArc(
//      center: pointA,
//      radius: halfLength * 2,
//      startAngle: 0.25 * .pi,
//      endAngle: 0,
//      clockwise: true
//    )
//    
//    // Create a dashed path
//    let dashPattern: [CGFloat] = [24.0, 8.0]
//    let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)
//    
//    let doorArcShape = createShapeNode(from: dashedArcPath)
//    doorArcShape.lineWidth = doorArcWidth
//    doorArcShape.zPosition = doorArcZPosition
//    
//    addChild(hideWallShape)
//    addChild(doorShape)
//    addChild(doorArcShape)
//    drawBackWallCaps()
//  }
//  
//  private func drawOpening() {
//    let openingPath = createPath(from: pointA, to: pointB)
//    
//    // Hide the wall underneath the opening
//    let hideWallShape = createShapeNode(from: openingPath)
//    hideWallShape.strokeColor = floorPlanBackgroundColor
//    hideWallShape.lineWidth = hideSurfaceWith
//    hideWallShape.zPosition = hideSurfaceZPosition
//    
//    addChild(hideWallShape)
//    drawBackWallCaps()
//  }
//  
//  private func drawWall() {
//    let wallPath = createPath(from: pointA, to: pointB)
//    let wallShape = createShapeNode(from: wallPath)
//    wallShape.lineCap = .round
//    
//    let dimensionsPath = createDimPath(from: pointADim, to: pointBDim)
//    let dimensionsShape = createDimNode(from: dimensionsPath)
//    dimensionsShape.lineCap = .round
//    
//    let dimensionsLabel = createDimLabel()
//    
//    addChild(wallShape)
//    addChild(dimensionsShape)
//    addChild(dimensionsLabel)
//  }
//  
//  private func drawWindow() {
//    let windowPath = createPath(from: pointA, to: pointB)
//    
//    // Hide the wall underneath the window
//    let hideWallShape = createShapeNode(from: windowPath)
//    hideWallShape.strokeColor = floorPlanBackgroundColor
//    hideWallShape.lineWidth = hideSurfaceWith
//    hideWallShape.zPosition = hideSurfaceZPosition
//    
//    // The window itself
//    let windowShape = createShapeNode(from: windowPath)
//    windowShape.lineWidth = windowWidth
//    windowShape.zPosition = windowZPosition
//    
//    addChild(hideWallShape)
//    addChild(windowShape)
//  
//    drawBackWallCaps()
//  }
//  
//  // MARK: - Helper functions
//  
//  private func createPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
//    let path = CGMutablePath()
//    path.move(to: pointA)
//    path.addLine(to: pointB)
//    
//    return path
//  }
//  
//  private func createDimPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
//    let path = CGMutablePath()
//    // edges of dimension line
//    path.move(to: CGPoint(x: pointA.x, y: pointA.y-surfacedWidth))
//    path.addLine(to: CGPoint(x: pointA.x, y: pointA.y+surfacedWidth))
//    path.move(to: CGPoint(x: pointB.x, y: pointB.y-surfacedWidth))
//    path.addLine(to: CGPoint(x: pointB.x, y: pointB.y+surfacedWidth))
//    
//    // main line with gap for label
//    path.move(to: pointA)
//    path.addLine(to: CGPoint(x: -dimensionLabelWidth/2, y: -dimensionLineDistFromSurface))
//    path.move(to: pointB)
//    path.addLine(to: CGPoint(x: dimensionLabelWidth/2, y: -dimensionLineDistFromSurface))
//    
//    return path
//  }
//  
//  
//  private func createDimLabel() -> SKLabelNode {
//    let dimTotalInches = self.capturedSurface.dimensions.x*metersToInchesFactor
//    let feet = Int(dimTotalInches/12)
//    let inches = Int(round(dimTotalInches)) % 12
//    
//    let label = SKLabelNode(text: "\(feet)' \(inches)''")
//    label.fontColor = floorPlanSurfaceColor
//    label.position.y = -dimensionLineDistFromSurface - labelFontSize/2
//    label.fontSize = labelFontSize
//    label.fontName = labelFont
//    
//    return label
//  }
//  
//  private func createShapeNode(from path: CGPath) -> SKShapeNode {
//    let shapeNode = SKShapeNode(path: path)
//    shapeNode.strokeColor = floorPlanSurfaceColor
//    shapeNode.lineWidth = surfacedWidth
//    
//    return shapeNode
//  }
//  
//  private func createDimNode(from path: CGPath) -> SKShapeNode {
//    let shapeNode = SKShapeNode(path: path)
//    shapeNode.strokeColor = floorPlanSurfaceColor
//    shapeNode.lineWidth = dimensionWidth
//    
//    return shapeNode
//  }
//  
//  private func drawBackWallCaps() {
//    let lineWidth: CGFloat = 1
//    let capA = SKShapeNode(circleOfRadius: surfacedWidth/2-lineWidth/2)
//    let capB = SKShapeNode(circleOfRadius: surfacedWidth/2-lineWidth/2)
//    capA.lineWidth = lineWidth
//    capB.lineWidth = lineWidth
//    capA.position = pointA
//    capB.position = pointB
//    capA.fillColor = floorPlanSurfaceColor
//    capB.fillColor = floorPlanSurfaceColor
//    capA.strokeColor = floorPlanSurfaceColor
//    capB.strokeColor = floorPlanSurfaceColor
//    capA.zPosition = hideSurfaceWallCapZPosition
//    capB.zPosition = hideSurfaceWallCapZPosition
//    
//    addChild(capA)
//    addChild(capB)
//  }
//}
//```
//
////
////  FloorPlanSurface.swift
////  floorplan
////
////  Created by teqnodux on 13/01/25.
////
//import SpriteKit
//import RoomPlan
//
//class FloorPlanSurface: SKNode {
//    
//    private let capturedSurface: CapturedRoom.Surface
//    
//    // MARK: - Computed properties
//    
//    private var halfLength: CGFloat {
//        return CGFloat(capturedSurface.dimensions.x) * scalingFactor / 2
//    }
//    
//    private var pointA: CGPoint {
//        return CGPoint(x: -halfLength, y: 0)
//    }
//    
//    private var pointB: CGPoint {
//        return CGPoint(x: halfLength, y: 0)
//    }
//    
//    private var pointC: CGPoint {
//        return pointB.rotateAround(point: pointA, by: 0.25 * .pi)
//    }
//    
//    // MARK: - Init
//    
//    init(capturedSurface: CapturedRoom.Surface) {
//        self.capturedSurface = capturedSurface
//        
//        super.init()
//        
//        // Set the surface's position using the transform matrix
//        let surfacePositionX = -CGFloat(capturedSurface.transform.position.x) * scalingFactor
//        let surfacePositionY = CGFloat(capturedSurface.transform.position.z) * scalingFactor
//        self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
//        
//        // Set the surface's zRotation using the transform matrix
//        self.zRotation = -CGFloat(capturedSurface.transform.eulerAngles.z - capturedSurface.transform.eulerAngles.y)
//        
//        // Draw the right surface
//        switch capturedSurface.category {
//        case .door:
//            drawDoor()
//        case .opening:
//            drawOpening()
//        case .wall:
//            drawWall()
//        case .window:
//            drawWindow()
//        case .floor:
//            nuli()
//        @unknown default:
//            drawWall()
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Draw
//    private func nuli(){
//        
//    }
//
//    private func drawDoor() {
//        let hideWallPath = createPath(from: pointA, to: pointB)
//        let doorPath = createPath(from: pointA, to: pointC)
//
//        // Hide the wall underneath the door
//        let hideWallShape = createShapeNode(from: hideWallPath)
//        hideWallShape.strokeColor = floorPlanBackgroundColor
//        hideWallShape.lineWidth = hideSurfaceWith
//        hideWallShape.zPosition = hideSurfaceZPosition
//        
//        // The door itself
//        let doorShape = createShapeNode(from: doorPath)
//        doorShape.lineCap = .square
//        doorShape.zPosition = doorZPosition
//        
//        // The door's arc
//        let doorArcPath = CGMutablePath()
//        doorArcPath.addArc(
//            center: pointA,
//            radius: halfLength * 2,
//            startAngle: 0.25 * .pi,
//            endAngle: 0,
//            clockwise: true
//        )
//        
//        // Create a dashed path
//        let dashPattern: [CGFloat] = [24.0, 8.0]
//        let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)
//
//        let doorArcShape = createShapeNode(from: dashedArcPath)
//        doorArcShape.lineWidth = doorArcWidth
//        doorArcShape.zPosition = doorArcZPosition
//        
//        addChild(hideWallShape)
//        addChild(doorShape)
//        addChild(doorArcShape)
//    }
//    
//    private func drawOpening() {
//        let openingPath = createPath(from: pointA, to: pointB)
//        
//        // Hide the wall underneath the opening
//        let hideWallShape = createShapeNode(from: openingPath)
//        hideWallShape.strokeColor = floorPlanBackgroundColor
//        hideWallShape.lineWidth = hideSurfaceWith
//        hideWallShape.zPosition = hideSurfaceZPosition
//        
//        addChild(hideWallShape)
//    }
//    
//    private func drawWall() {
//        let wallPath = createPath(from: pointA, to: pointB)
//        let wallShape = createShapeNode(from: wallPath)
//        wallShape.lineCap = .square
//
//        addChild(wallShape)
//    }
//    
//    private func drawWindow() {
//        let windowPath = createPath(from: pointA, to: pointB)
//        
//        // Hide the wall underneath the window
//        let hideWallShape = createShapeNode(from: windowPath)
//        hideWallShape.strokeColor = floorPlanBackgroundColor
//        hideWallShape.lineWidth = hideSurfaceWith
//        hideWallShape.zPosition = hideSurfaceZPosition
//        
//        // The window itself
//        let windowShape = createShapeNode(from: windowPath)
//        windowShape.lineWidth = windowWidth
//        windowShape.zPosition = windowZPosition
//        
//        addChild(hideWallShape)
//        addChild(windowShape)
//    }
//    
//    // MARK: - Helper functions
//    
//    private func createPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
//        let path = CGMutablePath()
//        path.move(to: pointA)
//        path.addLine(to: pointB)
//        
//        return path
//    }
//    
//    private func createShapeNode(from path: CGPath) -> SKShapeNode {
//        let shapeNode = SKShapeNode(path: path)
//        shapeNode.strokeColor = floorPlanSurfaceColor
//        shapeNode.lineWidth = surfaceWith
//        
//        return shapeNode
//    }
//    
//}
//
//i want to intigrate both in one code insttruct me with code snippets to impliment the code
