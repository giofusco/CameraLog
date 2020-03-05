//
//  ViewController.swift
//  CameraLog
//
//  Created by Giovanni Fusco on 2/28/20.
//  Copyright © 2020 Smith-Kettlewell Eye Research Institute. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSKView!
    var logger : Logger = Logger()
    var sessionID : String = ""
    var frameRate : Int = 10
    var rec : Bool = false
    var frameCnt : UInt64 = 0
    var lastProcessedFrameTime: TimeInterval = TimeInterval()

    @IBOutlet weak var recButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.session.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        logger.startSession(sessionID : sessionID)
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSKViewDelegate
    
    @IBAction func recPressed(_ sender: Any) {
        rec = !rec
        if rec{
            recButton.backgroundColor = .green
            recButton.setTitle("Pause", for: .normal)
        }
        else{
            recButton.backgroundColor = .red
            recButton.setTitle("REC", for: .normal)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        print(frame.timestamp-lastProcessedFrameTime)
        print(1000.0/Double(frameRate))
        if rec && (frame.timestamp-lastProcessedFrameTime) >= (1/Double(frameRate)){
//            logger.saveImage(imageToSave: frame.capturedImage, counter: frameCnt)
            frameCnt += 1
            logger.logData(currentARFrame: frame, cnt: frameCnt )
            lastProcessedFrameTime = frame.timestamp
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
