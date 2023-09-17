//
//  ARDisplayViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import ARKit
import SnapKit

class ARDisplayViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var imageToDisplay: UIImage?
    var lastAddedNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: view.frame)
        sceneView.delegate = self
        view.addSubview(sceneView)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastAddedNode?.removeFromParentNode()
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, types: .featurePoint)
        
        if let hitResult = hitResults.first {
            let transform = hitResult.worldTransform
            let position = SCNVector3(x: transform.columns.3.x, y: transform.columns.3.y, z: transform.columns.3.z)
            
            guard let image = imageToDisplay else { return }
            
            // Calculate aspect ratio
            let width = CGFloat(image.size.width)
            let height = CGFloat(image.size.height)
            
            let aspectRatio = width / height
            
            // Create plane with dynamic size
            let plane = SCNPlane(width: 0.1 * aspectRatio, height: 0.1)
            plane.firstMaterial?.diffuse.contents = image
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = position
            
            sceneView.scene.rootNode.addChildNode(planeNode)
            
            // Keep track of the last added node
            lastAddedNode = planeNode
        }
    }
}

extension ARDisplayViewController {
    private func setupUI() {
        let instructionLabel = UILabel()
        instructionLabel.text = "Tap where you want to place the image."
        instructionLabel.textColor = .white
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = .systemFont(ofSize: 24)
        view.addSubview(instructionLabel)
        
        instructionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.width.equalTo(view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width)
            make.centerX.equalToSuperview()
        }
        
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-32)
        }
    }
    
    @objc func didPinch(_ recognizer: UIPinchGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let hitResult = hitResults.first {
            let node = hitResult.node
            let scale = Float(recognizer.scale)
            node.scale = SCNVector3(x: scale, y: scale, z: scale)
        }
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
