//
//  PhysicsEnv.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 12/6/22.
//

import SwiftUI
import SpriteKit
import Foundation

class GameScene: SKScene {
    @ObservedObject var controls = UIJoin.shared
    
    
    // TODO: create object to store physics environment state
//    struct physicEnvStruct: Codable, Identifiable {
//        var id: ObjectIdentifier
//
//        // TODO: research how to make conform to encodable/decodable
//        var physicScene: SpriteView
//    }
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        // TODO: play with this (and allow user to)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    // release
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: use this to release object (instead of start of touch event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch controls.addMethod {
        case .clear:
            // select node and delete only that one
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                controls.selectedNode = touchedNodes[0]
            } else {
                // this removes the last node that was touched from being saved
                controls.selectedNode = SKNode()
            }
            controls.selectedNode.removeFromParent()
        case .add:
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                // check if selectedNode is paint node
                if touchedNodes[0].zPosition != -5 {
                    // log node so that drag motion works
                    controls.selectedNode = touchedNodes[0]
                    // if removeOn is set, clear node
                    if controls.removeOn {
                        controls.selectedNode.removeFromParent()
                    }
                } else {
                    // drop new one if paint node selected (can't move paint nodes)
                    print("You are selecting a paint node and need to drop instead")
                    let newNode = renderNode(location: location, hasPhysics: true)
                    addChild(newNode)
                }
            } else {
                // if no non-paint nodes are touched, then add new one
                let newNode = renderNode(location: location, hasPhysics: true)
                addChild(newNode)
            }
        case .paint:
            // remove paint
            let touchedNodes = nodes(at: location)
            
//            if touchedNodes.count > 0 {
//                let selectedNode = touchedNodes[0]
//                controls.selectedNodes = touchedNodes
//                if (Int(selectedNode.zPosition) == -5 && controls.addMethod == .paint && controls.removeOn) {
//                    controls.selectedNode = selectedNode
//                    controls.selectedNode.removeFromParent()
//                }
//            } else {  // add paint node
//                let newNode = renderNode(location: location, hasPhysics: false, zPosition: -5)
//                addChild(newNode)
//            }
        }
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
    
    // drag
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch controls.addMethod {
        case .clear:
            print("Will think about this clear method dragging finger")
        case .add:
            // TODO: check to see if there is only one touch for one finger, etc
            print(touches.count)
            for touch in touches {
                let location = touch.location(in: self)
                // do drag code
                if controls.selectedNodes.count > 0 {
                    // check if it is a paint node
                    if controls.selectedNode.zPosition != -5 {
                        // move with finger/mouse
                        controls.selectedNode.position = location
                    } else {
                        // do you need to drop on drag like this?
//                        let newNode = renderNode(location: location, hasPhysics: true)
//                        addChild(newNode)
                    }
                } else {
                    // pour code
                    if controls.pourOn {
                        let newNode = renderNode(location: location, hasPhysics: true)
                        addChild(newNode)
                    }
                    
                    // TODO: create camera code
                    // store current camera position before moving on
                    let originalCam = controls.camera.position  //camera.position
                    let center = view!.center
                    controls.camera.position = center
                    let xDist = location.x - center.x
                    let yDist = location.y - center.y
                    let distance = sqrt((xDist * xDist) + (yDist * yDist)) * 0.02
                    let xPos = xDist * distance * 0.08
                    let yPos = yDist * distance * 0.08
                    // TODO: disabling until stable
                    camera?.position.x = -xPos  // was +=
                    camera?.position.y = -yPos  // was -=

                    // force unwrap here assumes the camera was created in view
                    print("\(camera?.position.x), \(camera?.position.y)")
                    controls.camera = camera!
                    controls.gameScene.camera?.position = (location)
                }
            }
        case .paint:
            for touch in touches {
                let location = touch.location(in: self)
                let newNode = renderNode(location: location, hasPhysics: false, zPosition: -5)
                addChild(newNode)
            }
        }
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
 
    // tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
   
        print(touches.count)
        switch controls.addMethod {
        case .clear:
            // select node and delete only that one
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                controls.selectedNode = touchedNodes[0]
            } else {
                // this removes the last node that was touched from being saved
                controls.selectedNode = SKNode()
            }
            controls.selectedNode.removeFromParent()
        case .add:
            print("Add chosen")
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                // check if selectedNode is paint node
                if touchedNodes[0].zPosition != -5 {
                    // log node so that drag motion works
                    controls.selectedNode = touchedNodes[0]
                    // if removeOn is set, clear node
                    if controls.removeOn {
                        controls.selectedNode.removeFromParent()
                    }
                } else {
                    // drop new one if paint node selected (can't move paint nodes)
                    print("You are selecting a paint node and need to drop instead")
                    let newNode = renderNode(location: location, hasPhysics: true)
                    addChild(newNode)
                }
            } else {
                // if no non-paint nodes are touched, then add new one
                let newNode = renderNode(location: location, hasPhysics: true)
                addChild(newNode)
            }
        case .paint:
            // remove paint
            let touchedNodes = nodes(at: location)

            if touchedNodes.count > 0 {
                let selectedNode = touchedNodes[0]
                controls.selectedNodes = touchedNodes
                if (Int(selectedNode.zPosition) == -5 && controls.addMethod == .paint && controls.removeOn) {
                    controls.selectedNode = selectedNode
                    controls.selectedNode.removeFromParent()
                }
            } else {  // add paint node
                let newNode = renderNode(location: location, hasPhysics: false, zPosition: -5)
                addChild(newNode)
            }
        }
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }

}
