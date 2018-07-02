//
//  ViewController.swift
//  ARApp
//
//  Created by David Tacite on 27/06/2018.
//  Copyright © 2018 David Tacite. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate , ARSessionDelegate {
    
        //MARK: - outlets
    
    @IBOutlet weak var _label: UILabel!
    @IBOutlet weak var _ARView: ARSCNView!
    
    

    private var _nodes: [SCNNode] = []
    
        //MARK: - loadview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._ARView.delegate = self
        self._ARView.session.delegate = self
        
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
        self._createSphereNode(position: self._positionFromCamera())
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // si i ly as qu'un seul node on reactualise la position du node par rapport a la camera
        if self._nodes.count == 1 {
            guard let node = self._nodes.first else { return }
            let cameraPos = self._positionFromCamera()
            let nodePos = node.position
            self._distance(firstPos: cameraPos, secondPos: nodePos)
        }
    }
    
    
        //MARK: - private func
    
    // calcule de la distance entre deux positions
    private func _distance(firstPos: SCNVector3, secondPos: SCNVector3) {
        let firstPoint = GLKVector3Make(firstPos.x, firstPos.y, firstPos.z)
        let secondPoint = GLKVector3Make(secondPos.x, secondPos.y, secondPos.z)
        self._label.text = String(format: "Distance: %.2f meters", GLKVector3Distance(firstPoint, secondPoint))
    }
    
    // retourne la position de la Camera avancé de 0.1 metre
    private func _positionFromCamera() -> SCNVector3 {
        // retourne la position de la camera
        guard let currentFrame = self._ARView.session.currentFrame else { return SCNVector3Zero }
        let currentPos = currentFrame.camera.transform
        // crée une matrice identité 4x4
        var translation = matrix_identity_float4x4
        // ajoute une translation sur Z de -0.1
        translation.columns.3.z = -0.1
        let matrix = matrix_multiply(currentPos, translation)
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
        
    }
    
}

