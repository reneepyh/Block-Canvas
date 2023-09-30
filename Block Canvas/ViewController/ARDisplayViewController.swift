//
//  ARDisplayViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import ARKit
import SnapKit
import Lottie

class ARDisplayViewController: UIViewController, ARSCNViewDelegate {
    
    private var sceneView: ARSCNView!
    var imageToDisplay: UIImage?
    private var lastAddedNode: SCNNode?
    private var tapAnimationView: LottieAnimationView?
    private var pinchAnimationView: LottieAnimationView?
    
    private let instructionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.numberOfLines = 0
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        button.clipsToBounds = true
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.background.image = UIImage(systemName: "xmark.circle.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
        button.configuration = config
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.background.image = UIImage(systemName: "camera.viewfinder")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
        button.configuration = config
        return button
    }()
    
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
        view.addSubview(instructionButton)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16)
        config.background.backgroundColor = UIColor(hex: "192200", alpha: 0.6)
        config.attributedTitle = AttributedString("Tap where you want to place the image. Pinch to zoom.", attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.main(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.secondary]))
        instructionButton.configuration = config
        
        instructionButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().offset(-32)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(instructionButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-42)
            make.width.equalTo(58)
            make.height.equalTo(48)
        }
        
        // MARK: Lottie
        tapAnimationView = .init(name: "tap")
        tapAnimationView!.contentMode = .scaleAspectFit
        tapAnimationView!.loopMode = .repeat(2)
        tapAnimationView!.animationSpeed = 0.9
        view.addSubview(tapAnimationView!)
        tapAnimationView?.snp.makeConstraints({ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(150)
            make.bottom.equalTo(view.snp.bottom).offset(-200)
        })
        tapAnimationView!.play { (finished) in
            if finished {
                UIView.animate(withDuration: 0.5, animations: {
                    self.tapAnimationView?.alpha = 0
                }) { (completed) in
                    if completed {
                        self.tapAnimationView?.removeFromSuperview()
                        
                        self.pinchAnimationView = .init(name: "pinch to zoom")
                        self.pinchAnimationView!.contentMode = .scaleAspectFit
                        self.pinchAnimationView!.loopMode = .repeat(2)
                        self.pinchAnimationView!.animationSpeed = 0.5
                        self.view.addSubview(self.pinchAnimationView!)
                        self.pinchAnimationView?.snp.makeConstraints({ make in
                            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
                            make.centerX.equalTo(self.view.snp.centerX)
                            make.width.equalTo(150)
                            make.bottom.equalTo(self.view.snp.bottom).offset(-200)
                        })
                        self.pinchAnimationView!.play { (finished) in
                            if finished {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.pinchAnimationView?.alpha = 0
                                }) { (completed) in
                                    if completed {
                                        self.pinchAnimationView?.removeFromSuperview()
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
    
    @objc func cameraButtonTapped() {
        let capturedImage = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(capturedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            BCProgressHUD.showSuccess(text: "Saved Successfully", view: sceneView)
        }
    }
}
