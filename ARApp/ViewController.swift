//
//  ViewController.swift
//  ARApp
//
//  Created by David Tacite on 27/06/2018.
//  Copyright © 2018 David Tacite. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
        //MARK: - outlets
    
    @IBOutlet weak var _label: UILabel!
    @IBOutlet weak var _ARView: ARSCNView!
    
    

    private var _nodes: [SCNNode] = []
    
        //MARK: - loadview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._ARView.delegate = self
        
        // permet de configurer les options de l'arview
        self._ARView.showsStatistics = true
        self._ARView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // lance la session
        let configuration = ARWorldTrackingConfiguration()
        self._ARView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // met en pause la session
        self._ARView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        // on obtiens la position de l'endroit ou on a taper sur l'écran
        let currentTap = sender.location(in: self._ARView)
        // on obtiens le dernier point trouvé dans la scene
        guard let hitTest = self._ARView.hitTest(currentTap, types: .featurePoint).last else { return }
        let position = self._positionFromWorld(matrix: hitTest.worldTransform)
        
        self._createSphereNode(position: position)
        self._distance()
    }
    
        //MARK: - private func
    
    // calcule de la distance entre deux nodes
    private func _distance() {
        guard let firstNode = self._nodes.first, let secondNode = self._nodes.last else {return}
        let firstPoint = GLKVector3Make(firstNode.position.x, firstNode.position.y, firstNode.position.z)
        let secondPoint = GLKVector3Make(secondNode.position.x, secondNode.position.y, secondNode.position.z)
        self._label.text = String(format: "Distance: %.2f meters", GLKVector3Distance(firstPoint, secondPoint))
    }
    
    // retourne la position d'une matrix 4x4
    private func _positionFromWorld(matrix: matrix_float4x4) -> SCNVector3 {
        return SCNVector3(x: matrix.columns.3.x, y: matrix.columns.3.y, z:  matrix.columns.3.z)
    }
    
    // crée une sphere
    private func _createSphereNode(position: SCNVector3) {
        // si + de 2 spheres on les supprime
        if self._nodes.count == 2 {
            for node in self._nodes {
                node.geometry?.firstMaterial?.normal.contents = nil
                node.geometry?.firstMaterial?.diffuse.contents = nil
                // supprime le node de la stack de nodes de la scene
                node.removeFromParentNode()
            }
            self._nodes.removeAll()
        }
        let sphereNode = SCNNode()
        let sphere = SCNSphere(radius: 0.01)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.geometry = sphere
        sphereNode.position = position
        // on ajoute la sphereNode dans les nodes de la scene
        self._ARView.scene.rootNode.addChildNode(sphereNode)
        self._nodes.append(sphereNode)
//        var translation = matrix_identity_float4x4
  //      translation.columns.3.z = -0.5
    //    sphereNode.simdTransform = matrix_multiply((self._ARView.session.currentFrame?.camera.transform)!, translation)
        
    }
    
}

