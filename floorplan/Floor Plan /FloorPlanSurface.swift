//
//  FloorPlanSurface.swift
//  floorplan
//
//  Created by teqnodux on 13/01/25.
//  model 
import SpriteKit
import RoomPlan

class FloorPlanSurface: SKNode {
    
    private let capturedSurface: CapturedRoom.Surface
    private var surfaces: [CapturedRoom.Surface] = [] // Define surfaces here
    private var largestSurface: CapturedRoom.Surface?
    
    // MARK: - Computed properties
    
    private var halfLength: CGFloat {
        return CGFloat(capturedSurface.dimensions.x) * scalingFactor / 2
    }
    
    private var pointA: CGPoint {
        return CGPoint(x: -halfLength, y: 0)
    }
    private var pointADim: CGPoint {
      return CGPoint(x: -halfLength, y: -dimensionLineDistFromSurface)
    }

    
    private var pointB: CGPoint {
        return CGPoint(x: halfLength, y: 0)
    }
    
    private var pointBDim: CGPoint {
      return CGPoint(x: halfLength, y: -dimensionLineDistFromSurface)
    }
    
    private var pointC: CGPoint {
        return pointB.rotateAround(point: pointA, by: 0.25 * .pi)
    }
    private func getLargestSurface() {
        largestSurface = surfaces.first
        for surface in surfaces {
            if surface.dimensions.x > largestSurface?.dimensions.x ?? 0 {
                largestSurface = surface
            }
        }
    }

    
    // MARK: - Init
    
    init(capturedSurface: CapturedRoom.Surface) {
        self.capturedSurface = capturedSurface
        
        super.init()
        getLargestSurface()
        
        // Set the surface's position using the transform matrix
        let surfacePositionX = -CGFloat(capturedSurface.transform.position.x) * scalingFactor
        let surfacePositionY = CGFloat(capturedSurface.transform.position.z) * scalingFactor
        self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
                .rotateAround(point: CGPoint.zero, by: -CGFloat(largestSurface?.transform.eulerAngles.y ?? 0))
        
        // Set the surface's zRotation using the transform matrix
        self.zRotation = -CGFloat(capturedSurface.transform.eulerAngles.z - capturedSurface.transform.eulerAngles.y + (largestSurface?.transform.eulerAngles.y ?? 0))
        
        // Draw the right surface
        switch capturedSurface.category {
        case .door:
            nuli()
        case .opening:
            nuli()
        case .wall:
            drawWall()
        case .window:
            nuli()
        case .floor:
            nuli()
        @unknown default:
            drawWall()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    private func nuli(){
        
    }

    private func drawDoor() {
        let hideWallPath = createPath(from: pointA, to: pointB)
        let doorPath = createPath(from: pointA, to: pointC)

        // Hide the wall underneath the door
        let hideWallShape = createShapeNode(from: hideWallPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        // The door itself
        let doorShape = createShapeNode(from: doorPath)
        doorShape.lineCap = .square
        doorShape.zPosition = doorZPosition
        
        // The door's arc
        let doorArcPath = CGMutablePath()
        doorArcPath.addArc(
            center: pointA,
            radius: halfLength * 2,
            startAngle: 0.25 * .pi,
            endAngle: 0,
            clockwise: true
        )
        
        // Create a dashed path
        let dashPattern: [CGFloat] = [24.0, 8.0]
        let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)

        let doorArcShape = createShapeNode(from: dashedArcPath)
        doorArcShape.lineWidth = doorArcWidth
        doorArcShape.zPosition = doorArcZPosition
        
        addChild(hideWallShape)
        addChild(doorShape)
        addChild(doorArcShape)
    }
    
    private func drawOpening() {
        let openingPath = createPath(from: pointA, to: pointB)
        
        // Hide the wall underneath the opening
        let hideWallShape = createShapeNode(from: openingPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        addChild(hideWallShape)
    }
    
    private func drawWall() {
        let wallPath = createPath(from: pointA, to: pointB)
        let wallShape = createShapeNode(from: wallPath)
        wallShape.lineCap = .square
        // Create and draw dimension lines
           let dimensionsPath = createDimPath(from: pointADim, to: pointBDim)
           let dimensionsShape = createDimNode(from: dimensionsPath)
           dimensionsShape.lineCap = .round
           
           // Create dimension label
           let dimensionsLabel = createDimLabel()
           
           addChild(wallShape)
           addChild(dimensionsShape)
           addChild(dimensionsLabel)
    }
    private func createDimNode(from path: CGPath) -> SKShapeNode {
      let shapeNode = SKShapeNode(path: path)
      shapeNode.strokeColor = floorPlanSurfaceColor
      shapeNode.lineWidth = dimensionWidth
      
      return shapeNode
    }
    
    private func drawWindow() {
        let windowPath = createPath(from: pointA, to: pointB)
        
        // Hide the wall underneath the window
        let hideWallShape = createShapeNode(from: windowPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        // The window itself
        let windowShape = createShapeNode(from: windowPath)
        windowShape.lineWidth = windowWidth
        windowShape.zPosition = windowZPosition
        
        addChild(hideWallShape)
        addChild(windowShape)
    }
    
    // MARK: - Helper functions
    private func createDimPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        // Edge of dimension lines
        path.move(to: CGPoint(x: pointA.x, y: pointA.y - surfacedWidth))
        path.addLine(to: CGPoint(x: pointA.x, y: pointA.y + surfacedWidth))
        path.move(to: CGPoint(x: pointB.x, y: pointB.y - surfacedWidth))
        path.addLine(to: CGPoint(x: pointB.x, y: pointB.y + surfacedWidth))
        
        // Main line with gap for the label
        path.move(to: pointA)
        path.addLine(to: CGPoint(x: -dimensionLabelWidth / 2, y: -dimensionLineDistFromSurface))
        path.move(to: pointB)
        path.addLine(to: CGPoint(x: dimensionLabelWidth / 2, y: -dimensionLineDistFromSurface))
        
        return path
    }

    private func createDimLabel() -> SKLabelNode {
        let dimTotalInches = CGFloat(self.capturedSurface.dimensions.x) * CGFloat(metersToInchesFactor)

        let feet = Int(dimTotalInches / 12)
        let inches = Int(round(dimTotalInches)) % 12
        
        let label = SKLabelNode(text: "\(feet)' \(inches)''")
        label.fontColor = floorPlanSurfaceColor
        label.position.y = -dimensionLineDistFromSurface - labelFontSize / 2
        label.fontSize = labelFontSize
        label.fontName = labelFont
        
        return label
    }

    private func createPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: pointA)
        path.addLine(to: pointB)
        
        return path
    }
    
    private func createShapeNode(from path: CGPath) -> SKShapeNode {
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = floorPlanSurfaceColor
        shapeNode.lineWidth = surfaceWith
        
        return shapeNode
    }
    
}
