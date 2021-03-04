//
//  ViewController.swift
//  Walley
//
//  Created by Olena Stepaniuk on 03.03.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var currentAngleY: Float = 0.0
    var previousLoc = CGPoint.init(x: 0, y: 0)
    var isRotating = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSceneView()
        initScene()
        initARSession()
        loadModels()
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleNode))
        self.sceneView.addGestureRecognizer(scaleGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode))
        self.sceneView.addGestureRecognizer(rotationGesture)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        self.sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func upTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveUp = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 0.1), count: 1)
        nodeToMove.runAction(moveUp)
    }
    
    @IBAction func downTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveDown = SCNAction.repeat(SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 0.1), count: 1)
        nodeToMove.runAction(moveDown)
    }
    
    @IBAction func leftTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveLeft = SCNAction.repeat(SCNAction.moveBy(x: -0.05, y: 0, z: 0, duration: 0.1), count: 1)
        nodeToMove.runAction(moveLeft)
    }
    
    @IBAction func rightTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveRight = SCNAction.repeat(SCNAction.moveBy(x: 0.05, y: 0, z: 0, duration: 0.1), count: 1)
        nodeToMove.runAction(moveRight)
    }
    
    @IBAction func forwardTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveForward = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0, z: 0.05, duration: 0.1), count: 1)
        nodeToMove.runAction(moveForward)
    }
    
    @IBAction func backwardTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveBackward = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0, z: -0.05, duration: 0.1), count: 1)
        nodeToMove.runAction(moveBackward)
    }
    
    @IBAction func rotateTapped(_ sender: Any) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        let moveBackward = SCNAction.repeat(SCNAction.rotateBy(x: 0, y: CGFloat(0.1 * Double.pi), z: 0, duration: 0.1), count: 1)
        nodeToMove.runAction(moveBackward)
    }
  
    
    // MARK: - Initialization
    
    func initSceneView() {
        sceneView.delegate = self
    }
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        scene.physicsWorld.speed = 1
        //      scene.physicsWorld.timeStep = 1.0 / 60.0
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .vertical
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        sceneView.session.run(config)
    }
    
    func loadModels() {
        guard let paintingScene = SCNScene(named: "Paintings.scnassets/Paintings/Painting1.scn") else { return }
        
        guard let paintingNode = paintingScene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        
        sceneView.scene.rootNode.addChildNode(paintingNode)
    }
    
    @objc func scaleNode(gesture: UIPinchGestureRecognizer) {
        
        guard let nodeToScale = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
            nodeToScale.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
        
    }
    
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer) {
        
        guard let nodeToRotate = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        
        let rotation = Float(gesture.rotation)
        
        if gesture.state == .changed {
            isRotating = true
            nodeToRotate.eulerAngles.y = currentAngleY + rotation
        }
        
        if(gesture.state == .ended) {
            currentAngleY = nodeToRotate.eulerAngles.y
            isRotating = false
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let nodeToMove = sceneView.scene.rootNode.childNode(withName: "painting1", recursively: false) else { return }
        
        if !isRotating{
            
            let currentTouchPoint = gesture.location(in: self.sceneView)
            
            guard let hitTest = self.sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }
            
            let worldTransform = hitTest.worldTransform
            
            let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            
            nodeToMove.simdPosition = float3(newPosition.x, newPosition.y, newPosition.z)
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
}
