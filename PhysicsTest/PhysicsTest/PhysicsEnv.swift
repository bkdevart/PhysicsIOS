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
    
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()

    func didBegin(_ contact: SKPhysicsContact) {
//        &&
//            contact.bodyA.node?.name == "ball" &&
//            contact.bodyB.node?.name == "ball"
        print("Collision!")
        if contact.collisionImpulse > 5 {
            
            let shockwave = SKShapeNode(circleOfRadius: 1)

            shockwave.position = contact.contactPoint
            addChild(shockwave)
            
            shockwave.run(shockWaveAction)
        }
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
        /**
         # summary
         This function could be used to detect changes in the size of the app window and perform some actions accordingly (such as adjusting the layout of the app's UI).
         ## detail
         This is an "override" function in Swift, which means that it is replacing a default function that is called when a certain event occurs in the app. In this case, it is replacing the "didChangeSize" function, which is called when the size of the app's window changes.

         The function takes in an argument called "oldSize" which is of type CGSize. This argument represents the size of the app window before it was changed.

         In the body of the function, there are two lines of code that are currently commented out. These lines would increment a counter and print out a message indicating that the screen size has changed and the number of times it has changed.

         The final line of code prints out a message with the current size of the window.
         */
        // a number here to track (useful for debug for now)
//        controls.screenSizeChangeCount += 1
//        print("Screen changed \(controls.screenSizeChangeCount) times!")
//        print("New size:\(size)")
    }
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        /**
         # summary
         This is Swift code that overrides the method didMove(to view: SKView) in an SKScene subclass. It initializes the physics environment for the scene and sets up various gesture recognizers for the view.
         
         ## detail
         Specifically, it sets the physics body for the scene to be an edge loop with a certain size and a camera origin at the center. It also adds gesture recognizers for pinch zooming the camera, panning the camera, and moving the scene on the screen with three fingers. Lastly, it increments a variable timesAppLoaded to keep track of how many times the app has been loaded.
        */
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
        
        // hidden easter egg: 3 finger pan that moves scene on screen
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
        /**
         # summary
         This code seems to define a function named pinchDetected that handles a pinch gesture using UIPinchGestureRecognizer. The function updates the view's position based on the user's gesture.
         
         ## detail
         When the user starts pinching, the current position of the camera is saved, and the controls are marked as usingCamGesture.

         When the gesture is not cancelled, the scaling value of the camera is updated using the sender.scale property, and the cameraScale property is multiplied by 1 divided by the scale value. Additionally, the usingCamGesture property is set to false.

         If the gesture is cancelled, the camera scale is set back to the previous state, and usingCamGesture is also set to false.

         There is a TODO comment in the code that asks whether the camera reset is causing any issues, and future testing is suggested to verify this.
         */
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
        /**
         # summary
         This Swift programming code handles the camera pan gesture in an iOS app. It listens for UIPanGestureRecognizer events, which are generated when the user touches and drags on the screen.
         
         ## detail
         First, the code checks whether there is a valid view and camera to work with. Then, it calculates the translation of the gesture, which determines how much the camera should move in each direction based on the movement of the user's fingers.

         If the gesture is in the .began state, it records the starting position of the camera so that it can be moved relative to that position as the gesture progresses. It also sets a flag indicating that the gesture is currently being used to control the camera.

         If the gesture is in the .changed state, it updates the position of the camera based on the current translation and the starting position. It then sets the camera's new position and updates the flag to indicate that the gesture is no longer being used to control the camera.

         The code also includes commented-out logic for dealing with the .ended and .cancelled states, but it looks like this logic is still in development and may not be necessary for the final app.

         Finally, it includes TODO comments to remind the developer about tasks that still need to be completed or understood.
         */
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
        /**
         # summary
         This function allows a user to move a view around the screen with a three-finger gesture
         ## detail
         This code defines a function called "screenPanDetected" that handles the gesture of a user panning across the screen with multiple fingers. Specifically, if the gesture starts, the function saves the initial center of the view (which is being touched by the user, hence "sender.view"), and calculates the new center based on the translation (movement) of the view since the beginning of the gesture. If the gesture was not cancelled, the view is updated to the new center. If the gesture is cancelled (e.g. if the user stops touching the screen), the view is returned to its original location.
         ## joke
         But don't worry, if you tried to move a view with just two fingers, the code won't be fooled and won't work (that's its biggest joke, by the way).
         */
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
        /**
         # summary
         It is an override function that is called when the user ends touching the screen.

         ## detail
         The code first retrieves the location of the touch and identifies the nodes that are present on that location. If the controls are not in painting mode, it checks if any non-paint nodes are touched, and it sets the selected node to the first touched node. It also checks if the touched node is a paint node or not. If it's not a paint node, it prepares the node for drag motion, and if "removeOn" property is set, it removes the node. If it is a paint node, it allows the user to drop a new node if it's OK to do so. If no non-paint nodes are touched, it creates a new node according to the control settings and adds it as a child node. Finally, the game scene is set to the controls game scene.

         The code also contains some TODOs for future implementation and debugging prints which will help in identifying any issues.
         */
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
                    // put in lastNode as well for jump controls
                    controls.lastNode = touchedNodes[0]
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
                        addChild(newNode)  // did this use to activate before colision?
                        controls.lastNode = newNode
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
                    }
                    else if controls.playMode {
//                        renderRowShape(shape: .circle, location: location, kind: .limit)
                        renderFigShape(shape: .circle, location: location, kind: .pin)
                    } else {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                        controls.lastNode = newNode
                    }
                }
                controls.drop = true
            }
        }
        controls.gameScene = self
    }
    
    // drag
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /**
         # summary
         This Swift programming code is about handling touch events, specifically touchesMoved and touchesBegan events.
         
         ## detail
         In the touchesMoved function, the code is checking if the user is painting. If not, the code is checking if any physics node has been dragged and updating its position. If the user is painting, the code is trying to detect if the user is using the eraser or adding paint to the canvas.

         In the touchesBegan function, the code is checking if the user is selecting any non-paint node by tapping on it. If so, the node is logged for drag motion. If the user is painting, the code is checking if the user is using the eraser or adding paint to the canvas by tapping on it. Finally, the code is updating the controls structure and keeping track of all children objects (shape nodes).

         The code also contains several TODO comments that suggest there are some improvements that need to be made in the code logic. The code also uses some physics and node rendering functions that are not shown here.
         */
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
                        controls.lastNode = newNode
                    } // TODO: data selection is hitting here, put condition to handle different since it does a row at a time
                    else if controls.pourOn && controls.usingCamGesture == false && controls.selectedShape == .data {
                        let newNode = renderNode(location: location, hasPhysics: true, lastRed: lastRed, lastGreen: lastGreen, lastBlue: lastBlue, letterText: controls.letterText)
                        addChild(newNode)
                        controls.lastNode = newNode
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
                        controls.lastNode = newNode
                    }
                }
            }
        }
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
 
    // tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /**
         # summary
         This code is defining a function that is called whenever a touch is detected on a certain view in a Swift iOS app.
         
         ## description
         The function first checks which part of the screen was touched and then changes the background color of the view.
         
         Next, there is a conditional statement that checks whether or not painting is currently enabled in the app. If painting is not enabled, the function will execute code that allows the user to select non-paint nodes in the app. If painting is enabled, the function will execute code that allows the user to draw or remove paint nodes on the app.

         There are some comments throughout the code that suggest that there are more features that will be added or improvements that could be made in the future.
         */
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
                controls.lastNode = newNode
            }
        }
        
        // this is needed to keep track of all children objects (shape nodes)
        controls.gameScene = self
    }
    // TODO: create renderFigShape() and try making a stick figure
    func renderFigShape(shape: Shape, location: CGPoint, kind: JoinStyle) {
        /**
         # summary
         This code defines a function that takes in a "shape" object, a 2D point for location, and a "JoinStyle" variable "kind".
         
         ## description
         Within the function, it loads a single row of data, chooses a random color for the row, and creates two feature nodes, which are added to the scene as child nodes.

         The two nodes are then joined together using a "spring" joint, and the last node created is stored in a property called "lastNode".

         The rest of the code appears to be commented out for now, meaning it is not currently being executed. It looks like it creates more feature nodes and uses various types of joints to connect them together.
         */
        // flow is different since it does a row at a time
        let (data, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))
        
        let headNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.Outcome), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(headNode)
        
        let neckNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.id), chosenColor: rowColor, location: location, hasPhysics: true)
        addChild(neckNode)
        // TODO: temporarily trying head on sliding (it pops off!)
        pinJoinNodes(nodeA: headNode, nodeB: neckNode, kind: .spring, anchorX: 5.0,  anchorY: -5.0)

        controls.lastNode = neckNode
        
//        let chestNode = createFeatureNodeShape(shape: shape, scale: scaleData.Pregnancies, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(chestNode)
//        pinJoinNodes(nodeA: neckNode, nodeB: chestNode, kind: .pin, anchorY: -1.0)
//
//        let leftShoulderNode = createFeatureNodeShape(shape: shape, scale: scaleData.Glucose, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(leftShoulderNode)
//        pinJoinNodes(nodeA: chestNode, nodeB: leftShoulderNode, kind: .fixed, anchorX: -1.0)
//
//        let rightShoulderNode = createFeatureNodeShape(shape: shape, scale: scaleData.BloodPressure, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(rightShoulderNode)
//        pinJoinNodes(nodeA: chestNode, nodeB: rightShoulderNode, kind: .fixed, anchorX: 1.0)
//
//        let rightArmOneNode = createFeatureNodeShape(shape: shape, scale: scaleData.SkinThickness, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(rightArmOneNode)
//        pinJoinNodes(nodeA: rightShoulderNode, nodeB: rightArmOneNode, kind: .pin, anchorX: 1.0)
//
//        let rightArmTwoNode = createFeatureNodeShape(shape: shape, scale: scaleData.Insulin, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(rightArmTwoNode)
//        pinJoinNodes(nodeA: rightArmOneNode, nodeB: rightArmTwoNode, kind: .pin, anchorX: 1.0)
//
//        let rightArmThreeNode = createFeatureNodeShape(shape: shape, scale: scaleData.BMI, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(rightArmThreeNode)
//        pinJoinNodes(nodeA: rightArmTwoNode, nodeB: rightArmThreeNode, kind: .pin, anchorX: 1.0)
//
//        let elbowNode = createFeatureNodeShape(shape: shape, scale: scaleData.DiabetesPedigreeFunction, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(elbowNode)
//        pinJoinNodes(nodeA: rightArmThreeNode, nodeB: elbowNode, kind: .pin, anchorX: 1.0)
//
//        let foreArmOneNode = createFeatureNodeShape(shape: shape, scale: scaleData.Age, chosenColor: rowColor, location: location, hasPhysics: true)
//        addChild(foreArmOneNode)
//        pinJoinNodes(nodeA: elbowNode, nodeB: foreArmOneNode, kind: .pin, anchorX: 1.0)
    }
    
    func renderRowShape(shape: Shape, location: CGPoint, kind: JoinStyle) {
        /**
         # summary
         This is a function in Swift programming that renders a row of nodes, each representing a feature of a diabetes dataset.
         
         ## description
         The function starts by loading a row of data, choosing a random color for the row, and creating a node for the outcome feature (whether or not the person has diabetes) with a specific color and location. It then creates nodes for each of the other features in the row (ID, pregnancies, glucose level, blood pressure, skin thickness, insulin level, BMI, diabetes pedigree function, and age) and pins them to the previous node using a specific kind of joint. Finally, the last node of the row is set as the lastNode property of the controls object.
         */
        // flow is different since it does a row at a time
        let (data, scaleData) = controls.loadSingleRow()
        // choose random color for row
        let rowColor = Color(red: Double.random(in: 0.0...1.0), green: Double.random(in: 0.0...1.0), blue: Double.random(in: 0.0...1.0))

        // TODO: create toggles for features
//        let hasDiabetes = scaleData.Outcome == 1.0
        
        let outcomeNode = createFeatureNodeShape(shape: shape, scale: Float(scaleData.Outcome), chosenColor: rowColor, location: location, hasPhysics: true)
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
        
        controls.lastNode = ageNode
    }
    
    func renderRow(location: CGPoint, kind: JoinStyle) {
        /**
         # summary
         This Swift code creates a function called renderRow that renders a row of data.
         
         ## description
         The function loads a single row of data and chooses a random color for it. It then creates different nodes using a custom function called createFeatureNode, which takes in the chosen color, the location where the node will be placed, and some other parameters. The feature nodes created are for pregnancy, glucose, blood pressure, skin thickness, insulin, BMI, diabetes pedigree function, and age.

         pinJoinNodes is another custom function that creates a physics joint between two nodes; this function is used to create a connection between the feature nodes. Finally, the function creates an outcome node that is either a smiley or a frowny face depending on if the patient has diabetes.

         There are some TODO comments in the code that suggest some parts of it are temporary and may need further development or customization. Overall, this code appears to be part of a larger project related to diabetes data analysis and visualization.
         */
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
        
        controls.lastNode = idNode
    }
    
    func pinJoinNodes(nodeA: SKNode, nodeB: SKNode, kind: JoinStyle, anchorX: Float=0.0, anchorY: Float=0.0) {
        /**
         # summary
         This is a Swift function that creates various types of physics joints between two SKNodes.
         
         ## description
         The function takes in two SKNodes, a JoinStyle enum that specifies the type of joint to create, and optional Float values for setting the anchor position.

         Inside the function, there is a switch statement that determines which type of joint to create based on the provided JoinStyle enum. The function then calculates the anchor positions for each joint and creates the appropriate SKPhysicsJoint object using the attributes of the SKNodes. Finally, the joint is added to the physics world to apply the desired physics behavior between the two nodes. Depending on the type of joint, there are some TODOs that still need to be implemented. Overall, this function is used to add physics interactions between two SKNodes in a game or simulation.
         
         ## joke
         As a joke, did you hear about the programmer who was afraid of negative numbers? They’ll stop at nothing to avoid them!
         */
        switch kind {
        case .pin:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition)
            self.physicsWorld.add(newJoint)
        case .spring:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            // TODO: make inverse of anchorA
            let newAnchorXB = nodeB.position.x - CGFloat(anchorX)
            let newAnchorYB = nodeB.position.y - CGFloat(anchorY)
            let newAnchorBPosition = CGPoint(x: newAnchorXB, y: newAnchorYB)
            let newJoint = SKPhysicsJointSpring.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: newAnchorPosition, anchorB: newAnchorBPosition)
            self.physicsWorld.add(newJoint)
        case .limit:
            // TODO: see if you can modify anchor position
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)  // nodeA.position
            let newJoint = SKPhysicsJointLimit.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: newAnchorPosition, anchorB: nodeB.position)
            self.physicsWorld.add(newJoint)
        case .fixed:
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointFixed.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition)
            self.physicsWorld.add(newJoint)
        case .sliding:
            // using this on everything causes performance issues
            let newAnchorX = nodeA.position.x + CGFloat(anchorX)
            let newAnchorY = nodeA.position.y + CGFloat(anchorY)
            let newAnchorPosition = CGPoint(x: newAnchorX, y: newAnchorY)
            let newJoint = SKPhysicsJointSliding.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: newAnchorPosition, axis: CGVector(dx: 1.0, dy: 1.0))
            self.physicsWorld.add(newJoint)
        }
        
    }
}
