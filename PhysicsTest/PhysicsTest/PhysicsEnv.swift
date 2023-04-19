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
    
    @AppStorage("TimesAppLoaded") private var timesAppLoaded = 0
    @AppStorage("LastRed") private var lastRed = 0.0
    @AppStorage("LastGreen") private var lastGreen = 0.43
    @AppStorage("LastBlue") private var lastBlue = 0.83
    // vars used for camera gestures
    var initialCenter = CGPoint()
    var startX = CGFloat()
    var startY = CGFloat()
    var cameraScale = CGFloat()
    
    enum JoinStyle: String {
        case pin = "pin"
        case spring = "spring"
        case limit = "limit"
        case fixed = "fixed"
        case sliding = "sliding"
    }
    
    // info on gesture recognizers: https://developer.apple.com/documentation/uikit/uigesturerecognizer
    
    // TODO: create object to store physics environment state
//    struct physicEnvStruct: Codable, Identifiable {
//        var id: ObjectIdentifier
//
//        // TODO: research how to make conform to encodable/decodable
//        var physicScene: SpriteView
//    }

    
    // TODO:  override the scene’s didChangeSize(_:) method, which is called whenever the scene changes size. When this method is called, you should update the scene’s contents to match the new size.
    override func didChangeSize(_ oldSize: CGSize) {
        // a number here to track (useful for debug for now)
//        controls.screenSizeChangeCount += 1
//        print("Screen changed \(controls.screenSizeChangeCount) times!")
//        print("New size:\(size)")
    }
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        // initialize physics environment
//        let defaults = UserDefaults.standard
        timesAppLoaded += 1
        // playview will be mulitiplied by screenMultiply
        let screenSizeX = 428.0  // dynamically do this later
        let physicsSize = screenSizeX * controls.physicsEnvScale
        let cameraOrigin = CGPoint(x: 0, y: 0)  // x was (physicsSize / 2)
        controls.cameraOrigin = cameraOrigin
        let physicsZone = CGRect(origin: cameraOrigin, size: CGSize(width: physicsSize, height: physicsSize))
        // TODO: figure out how to put an outline around edgeLoop
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsZone)
        
        // not using this, keeping in case a use appears
//        let swipeRight = UISwipeGestureRecognizer(target: self,
//            action: #selector(GameScene.swipeRight(sender:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
        
        // adding pinch recgonizer for camera zoom
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(GameScene.pinchDetected(sender:)))
        view.addGestureRecognizer(pinch)
        
        // adding camera PanGestureRecognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panDetected(sender:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        view.addGestureRecognizer(pan)
        
        // adding hidden 3 finger pan that moves scene on screen
        let moveScreen = UIPanGestureRecognizer(target: self, action: #selector(GameScene.screenPanDetected(sender:)))
        moveScreen.minimumNumberOfTouches = 3
        moveScreen.maximumNumberOfTouches = 3
        view.addGestureRecognizer(moveScreen)
    }
    
    // not using this, keeping in case a use appears
//    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
//        // Handle the swipe
//        print("Swiped right!")
//    }
    
    @objc func pinchDetected(sender: UIPinchGestureRecognizer) {
        // handle the pinch using scale value
        guard camera != nil else {return}

        if sender.state == .began {
            // if controls aren't updated, view will snap back to old position
            cameraScale = controls.camera.xScale
            controls.usingCamGesture = true
        }
        // Update the position for the .began, .changed, and .ended states
        if sender.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            let newScale = cameraScale * 1 / sender.scale
            camera?.setScale(newScale)
            controls.camera.xScale = newScale
            controls.usingCamGesture = false
       } else {
            // On cancellation, return the piece to its original location.
           // TODO: is this causing camera reset?  - continue testing to verify
           camera?.setScale(cameraScale)
            controls.usingCamGesture = false
       }
    }
    
    // https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
    @objc func panDetected(sender: UIPanGestureRecognizer) {
        // handle the camera pan
        guard sender.view != nil else {return}
        guard camera != nil else {return}
//        let piece = sender.view!
        
        // translation gives us the center point between two fingers touching for pan
        let translation = sender.translation(in: sender.view!.superview)
        // starting to pan, two fingers down
        print(sender.state)
        
        if sender.state == .began {
           // Retreive the camera's original position
            self.startX = controls.camera.position.x
            self.startY = controls.camera.position.y
            controls.usingCamGesture = true
        }
        
        // continuing to pan with fingers
        if sender.state == .changed
        {
            // Add the X and Y translation to the view's original position.
            camera?.position.x = self.startX - translation.x
            camera?.position.y = self.startY + translation.y
            controls.camera.position = camera!.position
            controls.usingCamGesture = false
        }
                
//        // lifting fingers from screen (end of pan)
//        if sender.state == .ended {
//            print("Ended")
//            // On cancellation, return the piece to its original location.
//            // TODO: not sure if this logic is needed (may cause view reset) - continue to test
//            camera?.position.x = self.startX
//            camera?.position.y = self.startY
//            controls.camera.position = camera!.position
//            controls.usingCamGesture = false
//            // TODO: update startX & startY?
//
//        }
        
        // TODO: understand what .cancelled represents - may not belong to this gesture
        if sender.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            camera?.position.x = self.startX - translation.x
            camera?.position.y = self.startY + translation.y
            controls.camera.position = camera!.position
            controls.usingCamGesture = false

            // TODO: do you need to update startX & startY?

        }
        // TODO: make sure you are covering all states explicitely (no else at the end)

    }
    
    @objc func screenPanDetected(sender: UIPanGestureRecognizer) {
        // this code moves the entire view as 3 finger gesture
        guard sender.view != nil else {return}
        let piece = sender.view!
        
        let translation = sender.translation(in: piece.superview)
           if sender.state == .began {
               // Save the view's original position.
               // TODO: this might be causing unnesessary re-centering
               self.initialCenter = piece.center
           }
            // Update the position for the .began, .changed, and .ended states
           if sender.state != .cancelled {
              // Add the X and Y translation to the view's original position.
              let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
              piece.center = newCenter
           }
           else {
              // On cancellation, return the piece to its original location.
              piece.center = initialCenter
           }
    }

    // release
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // using this to release physics objects (instead of start of touch event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if controls.isPainting == false {
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                // check if selectedNode is paint node
                if touchedNodes[0].zPosition != -5 {
                    // log node so that drag motion works
                    controls.selectedNode = touchedNodes[0]
                    // turn drop switch off
                    controls.drop = false
                    // if removeOn is set, clear node
                    if controls.removeOn {
                        // TODO: see which conditions this runs (breakpoint doesn't always trigger when toggling, clicking)
                        print(controls.selectedNode)
                        controls.selectedNode.removeFromParent()
                    }
                } else {
                    // drop new one if paint node selected (can't move paint nodes)
                    print("You are selecting a paint node and need to drop instead")
                    if controls.drop && !controls.removeOn && controls.usingCamGesture == false {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                    } else if !controls.removeOn && controls.isPainting {
                        // TODO: update selected node so that paint node can be deleted
                        controls.selectedNode = touchedNodes[0]
                    }
                }
            } else {
                // if no non-paint nodes are touched, then add new one
                if controls.drop && !controls.removeOn && controls.usingCamGesture == false {
                    if controls.selectedShape == .data {
                        renderRow(location: location, kind: .limit)
//                        renderRowShape(shape: .rectangle, location: location, kind: .limit)
                    } else {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                    }
                }
                controls.drop = true
            }
        }
        controls.gameScene = self
    }
    
    // drag
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // TODO: refactor this logic (too complex with new interface, jittery animation and bugs)
        // dropping physics object
        if controls.isPainting == false {
            for touch in touches {
                let location = touch.location(in: self)
                // dragging physics node code
                if controls.selectedNodes.count > 0 {
                    // check if it is a paint node
                    if controls.selectedNode.zPosition != -5 {
                        // move with finger/mouse
                        controls.selectedNode.position = location
                        controls.drop = false
                    }
                } else {
                    // pour code
                    
                    if controls.pourOn && controls.usingCamGesture == false && controls.selectedShape != .data {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                    } // TODO: data selection is hitting here, put condition to handle different since it does a row at a time
                    else if controls.pourOn && controls.usingCamGesture == false && controls.selectedShape == .data {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                    }
                }
            }
        } else {
            // erasing painting, dragging paint
            if (controls.usingCamGesture == false) {
                for touch in touches {
                    let location = touch.location(in: self)
                    let touchedNodes = nodes(at: location)
                    controls.selectedNodes = touchedNodes
                    // check for eraser, remove paint
                    if touchedNodes.count > 0 && controls.removeOn {
                        // check if selectedNode is paint node
                        if touchedNodes[0].zPosition == -5 {
                            // log node and remove
                            controls.selectedNode = touchedNodes[0]
                            controls.selectedNode.removeFromParent()
                        }
                    } else {
                        // paint
                        let location = touch.location(in: self)
                        let newNode = renderNode(location: location, hasPhysics: false, zPosition: -5, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                    }
                }
            }
        }
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
 
    // tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        backgroundColor = UIColor(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), alpha: 0.5)
   
        // non-paint node selection
        // TODO: re-evaluate if you want to exclude data here (need to move data code)
        if controls.isPainting == false {  // && controls.selectedShape != .data
            // TODO: see what you neeed to keep from this code after implementing drop (touchesEnded)
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
                }
            }
        } else {
            // remove paint
            let touchedNodes = nodes(at: location)

            if touchedNodes.count > 0 {
                let selectedNode = touchedNodes[0]
                controls.selectedNodes = touchedNodes
                if (Int(selectedNode.zPosition) == -5 && controls.removeOn) {
                    controls.selectedNode = selectedNode
                    controls.selectedNode.removeFromParent()
                }
            } else if controls.usingCamGesture == false && controls.selectedShape != .data {  // add paint node
                let newNode = renderNode(location: location, hasPhysics: false, zPosition: -5, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                addChild(newNode)
            } // else if controls.usingCamGesture == false && controls.selectedShape == .data {
                // data drop
//                renderRow(location: location, kind: .limit)
//                renderRowShape(shape: Shape.circle, location: location, kind: .limit)
//                renderPersonShape(shape: Shape.circle, location: location, kind: .limit)
//            }
        }
        
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
    // TODO: create renderPersonShape() and try making a stick figure
    func renderPersonShape(shape: Shape, location: CGPoint, kind: JoinStyle) {
        // flow is different since it does a row at a time
        let (data, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: may need to use this to properly render shapes for outcome
        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNodeShape(shape: shape, scale: 1.0, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(outcomeNode)
        
        let idNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(idNode)
        // TODO: temporarily trying head on sliding (it pops off)
        pinJoinNodes(nodeA: outcomeNode, nodeB: idNode, kind: .sliding)

        let pregnanciesNode = createFeatureNodeShape(shape: shape, scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(pregnanciesNode)
        pinJoinNodes(nodeA: idNode, nodeB: pregnanciesNode, kind: kind)

        let glucoseNode = createFeatureNodeShape(shape: shape, scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(glucoseNode)
        pinJoinNodes(nodeA: pregnanciesNode, nodeB: glucoseNode, kind: kind)

        let bloodPressureNode = createFeatureNodeShape(shape: shape, scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(bloodPressureNode)
        pinJoinNodes(nodeA: idNode, nodeB: bloodPressureNode, kind: kind)

        let skinThicknessNode = createFeatureNodeShape(shape: shape, scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(skinThicknessNode)
        pinJoinNodes(nodeA: bloodPressureNode, nodeB: skinThicknessNode, kind: kind)

        let insulinNode = createFeatureNodeShape(shape: shape, scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(insulinNode)
        pinJoinNodes(nodeA: skinThicknessNode, nodeB: insulinNode, kind: kind)

        let BMINode = createFeatureNodeShape(shape: shape, scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(BMINode)
        pinJoinNodes(nodeA: insulinNode, nodeB: BMINode, kind: kind)

        let diabetesPedigreeFunctionNode = createFeatureNodeShape(shape: shape, scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(diabetesPedigreeFunctionNode)
        pinJoinNodes(nodeA: BMINode, nodeB: diabetesPedigreeFunctionNode, kind: kind)

        let ageNode = createFeatureNodeShape(shape: shape, scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(ageNode)
        pinJoinNodes(nodeA: diabetesPedigreeFunctionNode, nodeB: ageNode, kind: kind)
    }
    
    func renderRowShape(shape: Shape, location: CGPoint, kind: JoinStyle) {
        // flow is different since it does a row at a time
        let (data, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: create toggles for features
        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNodeShape(shape: shape, scale: 1.0, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(outcomeNode)
        
        let idNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(idNode)
        // TODO: temporarily trying head on sliding (it pops off)
        pinJoinNodes(nodeA: outcomeNode, nodeB: idNode, kind: .sliding)

        let pregnanciesNode = createFeatureNodeShape(shape: shape, scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(pregnanciesNode)
        pinJoinNodes(nodeA: idNode, nodeB: pregnanciesNode, kind: kind)

        let glucoseNode = createFeatureNodeShape(shape: shape, scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(glucoseNode)
        pinJoinNodes(nodeA: pregnanciesNode, nodeB: glucoseNode, kind: kind)

        let bloodPressureNode = createFeatureNodeShape(shape: shape, scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(bloodPressureNode)
        pinJoinNodes(nodeA: glucoseNode, nodeB: bloodPressureNode, kind: kind)

        let skinThicknessNode = createFeatureNodeShape(shape: shape, scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(skinThicknessNode)
        pinJoinNodes(nodeA: bloodPressureNode, nodeB: skinThicknessNode, kind: kind)

        let insulinNode = createFeatureNodeShape(shape: shape, scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(insulinNode)
        pinJoinNodes(nodeA: skinThicknessNode, nodeB: insulinNode, kind: kind)
        
        let BMINode = createFeatureNodeShape(shape: shape, scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(BMINode)
        pinJoinNodes(nodeA: insulinNode, nodeB: BMINode, kind: kind)
        
        let diabetesPedigreeFunctionNode = createFeatureNodeShape(shape: shape, scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(diabetesPedigreeFunctionNode)
        pinJoinNodes(nodeA: BMINode, nodeB: diabetesPedigreeFunctionNode, kind: kind)
        
        let ageNode = createFeatureNodeShape(shape: shape, scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(ageNode)
        pinJoinNodes(nodeA: diabetesPedigreeFunctionNode, nodeB: ageNode, kind: kind)

        
//        pinJoinNodes(nodeA: ageNode, nodeB: outcomeNode, kind: .sliding)
    }
    
    func renderRow(location: CGPoint, kind: JoinStyle) {
        // flow is different since it does a row at a time
        let (data, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: create toggles for features
        let idNode = createFeatureNode(text: "i", scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(idNode)

        let pregnanciesNode = createFeatureNode(text: "P", scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(pregnanciesNode)
        pinJoinNodes(nodeA: idNode, nodeB: pregnanciesNode, kind: kind)

        let glucoseNode = createFeatureNode(text: "G", scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(glucoseNode)
        pinJoinNodes(nodeA: pregnanciesNode, nodeB: glucoseNode, kind: kind)

        let bloodPressureNode = createFeatureNode(text: "b", scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(bloodPressureNode)
        pinJoinNodes(nodeA: glucoseNode, nodeB: bloodPressureNode, kind: kind)

        let skinThicknessNode = createFeatureNode(text: "S", scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(skinThicknessNode)
        pinJoinNodes(nodeA: bloodPressureNode, nodeB: skinThicknessNode, kind: kind)

        let insulinNode = createFeatureNode(text: "I", scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(insulinNode)
        pinJoinNodes(nodeA: skinThicknessNode, nodeB: insulinNode, kind: kind)
        
        let BMINode = createFeatureNode(text: "B", scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(BMINode)
        pinJoinNodes(nodeA: insulinNode, nodeB: BMINode, kind: kind)
        
        let diabetesPedigreeFunctionNode = createFeatureNode(text: "D", scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(diabetesPedigreeFunctionNode)
        pinJoinNodes(nodeA: BMINode, nodeB: diabetesPedigreeFunctionNode, kind: kind)
        
        let ageNode = createFeatureNode(text: "A", scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(ageNode)
        pinJoinNodes(nodeA: diabetesPedigreeFunctionNode, nodeB: ageNode, kind: kind)

        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNode(text: hasDiabetes ? "☹︎" : "☻", scale: 1.0, chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(outcomeNode)
        // TODO: temporarily trying head on sliding (it pops off)
        pinJoinNodes(nodeA: ageNode, nodeB: outcomeNode, kind: .sliding)
    }
    
    func pinJoinNodes(nodeA: SKNode, nodeB: SKNode, kind: JoinStyle) {
        switch kind {
        case .pin:
            let newJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: nodeA.position)
            self.physicsWorld.add(newJoint)
        case .spring:
            let newJoint = SKPhysicsJointSpring.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: nodeA.position, anchorB: nodeB.position)
            self.physicsWorld.add(newJoint)
        case .limit:
            let newJoint = SKPhysicsJointLimit.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: nodeA.position, anchorB: nodeB.position)
            self.physicsWorld.add(newJoint)
        case .fixed:
            let newJoint = SKPhysicsJointFixed.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: nodeA.position)
            self.physicsWorld.add(newJoint)
        case .sliding:
            // using this on everything causes performance issues
            let newJoint = SKPhysicsJointSliding.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: nodeA.position, axis: CGVector(dx: 1.0, dy: 1.0))
            self.physicsWorld.add(newJoint)
        }
        
    }
}
