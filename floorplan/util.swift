import UIKit
import SceneKit

func generate2DThumbnail(filePath: String) -> UIImage? {
    let scene = SCNScene(named: filePath)
    let scnView = SCNView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    scnView.scene = scene
    scnView.allowsCameraControl = true
    return scnView.snapshot()
}
