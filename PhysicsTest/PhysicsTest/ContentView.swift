//
//  ContentView.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/18/22.

/*
 Features
 - Physics environment
    - be able to pause environment at any time, then switch factors like gravity, friction, etc and see what happens
    - be able to switch between many different environment parameters
    - be able to save environment and load later
        - can also be used to solve navigational issues when switching screens
 - Shapes
    - make user-defined shapes
 - Interaction
    - have mode that pauses physics/other interactions and allows you to place items locked in place
    - (other mode) combine drag and pour methods into dynamic action
        - if tapping a node, go into drag mode
        - if not tapping a node, go into drop/pour mode based on if tap or drag motion
        - have toggle mode for clearing nodes (on/off switch)
        - add paint mode switch
 
 Bugs
 - pan gesture - with pour on weird things happen
 - Adding a node can happen sometimes when dragging one (it appears watching others)
 - Drag method that checks for background layer makes drag very jittery, sometimes objects drop and return to mouse
 - Pour method does not work when there is a background node where touch starts
 - Rectangle height not working when clear & static, physics not applying at one point
 - Clear all can get stuck, when tapping screen after, clear catches up
 - Clear all removes camera node
 
 Interface ideas
 - anything delightful
 - replace camera toggle with paint toggle, remove add/paint dropdown
 - see if it's possible to make slider button change to complementary color
 
 Code ideas
 - Look at changing from a shared control object to some kind of delegate model
 
 Feature ideas
 - Persistance - save state whenever phone is turned
    - Allow user to set number of saves (just rolls and deletes old as new added)
    - Allow user to favorite saves so that they are never deleted
 - figure out how to put an outline around edgeLoop
 - ml paint - once you can save scenes, make images for each one and have ml generate new background scenes for user in their "style"
 - make all objects physics objects that fall when you clear (fall to infinity)
 - Let user change paint objects into physics objects (make toggle switch for falling ball) - figure.fall.circle, digitalcrown.arrow.counterclockwise.fill
 - add option to shade objects and show they are rotating
 - Debug window - have listview that shows all nodes along with their properties when selected
 - Adjust gravity based on tilt of phone
 - Add velocity direction to play with damping (applyForce & applyImpulse)
 - make new view, use pop up menu to put all controls in to free up screen
 
 Game ideas
 - Quantum wall
 - Wrecking ball
 - Obstacle navigation
 - Boom blox
 - Gravity (simulate planets)
 - Different modes (sassy mode tells you things that are misleading like it erased when it saved, etc)

 */

import SwiftUI
import CoreData
import SpriteKit

enum Shape: String, CaseIterable, Identifiable {
    case rectangle, circle, triangle
    var id: Self { self }
}

enum AddMethod: String, CaseIterable, Identifiable {
    case add, paint, clear
    var id: Self { self }
}


struct ContentView: View {
    @Environment(\.colorScheme) var currentMode
    // default box/color values - these are initialized in UIJoin (may not need values?)
    // TODO: these values are synced with default values in UIJoin - make all in one place?
    // value may be needed at start (based on how initialization is handled)
    // Cannot use instance member 'controls' within property initializer; property initializers run before 'self' is available
    @State private var boxHeight = 6.0
    @State private var boxWidth = 6.0
    @State private var r =  0.0  // 0.34, 0.62
    @State private var g = 0.43  // 0.74, 0.53
    @State private var b = 0.83  // 0.7, 1.0
    @State private var sceneHeight = 500
    @State private var density = 1.0  // 1.0
    @State private var staticNode = false
    @State private var linearDamping = 0.1
    
    
    // using this to track box size and color selection as it changes
    let controls = UIJoin.shared

    // houses shape picker selection
    @State private var selectedShape: Shape = .rectangle
    @State private var addMethod: AddMethod = .add
    @State public var removeOn = false
    @State public var pourOn = false
    @State public var isPainting = false
//    @State public var cameraLocked = true
    @State public var cameraZoom = 1.0
    @GestureState var magnifyBy = 1.0

    
    var scene: SKScene {
        // making this square helps with ratio issues when drawing shapes
        let scene = GameScene()
        // TODO: make sure dynamic sizing is working properly - not sure if this is used
        let maxHeight = controls.screenHeight  // 2532
        let maxWidth = controls.screenWidth  // 1170
        // TODO: create variable with smaller of two screen values to use for resizing
        var scalePixels = 1.0  // generic default value
        if maxHeight > maxWidth {
            scalePixels = maxWidth
        } else {
            scalePixels = maxHeight
        }
        controls.scalePixels = scalePixels
        scene.size = CGSize(width: scalePixels, height: scalePixels)
        scene.scaleMode = .aspectFit  // .aspectFill // .resizeFill  // .aspectFit
        scene.view?.showsDrawCount = true
        // making complementary color of chosen object color
        scene.backgroundColor = UIColor(red: abs(r - 1.0), green: abs(g - 1.0), blue: abs(b - 1.0), alpha: 0.5)
        
        // add camera node
        let cameraNode = SKCameraNode()
        // place this at the center bottom of physics view
        cameraNode.position = CGPoint(x: scene.size.height * controls.physicsEnvScale,
                                      y: scene.size.height / 2)
        scene.addChild(cameraNode)
        scene.camera = cameraNode
        
        // update shared references
        controls.gameScene = scene
        controls.camera = cameraNode
        
        return scene
    }
   
    
    struct PourToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                            "drop.fill" : "drop")
                        .renderingMode(.template)
//                        .foregroundColor(configuration.isOn ? .cyan : .black)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    struct StaticToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "hand.raised.brakesignal": "brakesignal")
                        .renderingMode(.template)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    struct ClearToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "eraser.fill": "eraser")
                        .renderingMode(.template)
                        // this is a workaround to keep the window from resizing and clearing sprite objects
//                        .font(configuration.isOn ? .system(size: 50) : .system(size: 49))
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // this works opposite due to variable being set to false by default
    struct PaintToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                          "paintbrush.fill": "paintbrush")
                        .renderingMode(.template)
//                        .font(configuration.isOn ? .system(size: 50) : .system(size: 51))
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                VStack {
                    // TODO: find a way to use Geometry Reader to dynamically fit and keep correct ratio for boxes
                    // LayoutAndGeometry from 100 days of swiftui could be helpful
                    HStack {
                        VStack {
                            Picker("Shape", selection: $selectedShape) {
                                Text("Rectangle").tag(Shape.rectangle)
                                Text("Circle").tag(Shape.circle)
                                Text("Triangle").tag(Shape.triangle)
                            }
                            .onChange(of: selectedShape, perform: shapeChanged)
//                            Text("\(selectedShape.rawValue) size")
                            
                            HStack {
                                Text("H")
                                    .foregroundColor(Color(red: r, green: g, blue: b))
                                Slider(value: $boxHeight, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxHeight, perform: sliderBoxHeightChanged)
                            }
                            HStack {
                                Text("W")
                                    .foregroundColor(Color(red: r, green: g, blue: b))
                                Slider(value: $boxWidth, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxWidth, perform: sliderBoxWidthChanged)
                            }
                        }
                        .padding()
                        VStack {
                            VStack {
                                // TODO: see if you can caculate complimentary color to current and adjust RGB text to match
                                HStack {
                                    Text("R")
                                        .foregroundColor(Color(red: (r - 0.5), green: (g - 0.5), blue: (b - 0.5), opacity: r))
                                    Slider(value: $r, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: r, perform: sliderColorRChanged)
                                }
                                HStack {
                                    Text("G")
                                        .foregroundColor(Color(red: r - 0.5, green: g - 0.5, blue: b - 0.5, opacity: g))
                                    Slider(value: $g, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: g, perform: sliderColorGChanged)
                                }
                                HStack {
                                    Text("B")
                                        .foregroundColor(Color(red: r - 0.5, green: g - 0.5, blue: b - 0.5, opacity: b))
                                    Slider(value: $b, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: b, perform: sliderColorBChanged)
                                }
                                
                            }
                            .padding()
                            .background(Color(red: r, green: g, blue: b))  // gives preview of chosen color
                            .cornerRadius(20)
                        }
                        .padding()
                    }
                    // Toggle buttons
                    HStack {
                        Toggle("Clear", isOn: $removeOn)
                            .onChange(of: removeOn) { newValue in
                                controls.removeOn = removeOn
                            }
                            .toggleStyle(ClearToggleStyle())
                            .foregroundColor(Color(red: r, green: g, blue: b))
                        Toggle("Static", isOn: $staticNode)
                            .onChange(of: staticNode) { newValue in
                                controls.staticNode = staticNode
                            }
                            .toggleStyle(StaticToggleStyle())
                            .foregroundColor(Color(red: r, green: g, blue: b))
                        Toggle("Pour", isOn: $pourOn)
                            .toggleStyle(PourToggleStyle())
                            .foregroundColor(Color(red: r, green: g, blue: b))
                            .onChange(of: pourOn) { newValue in
                                controls.pourOn = pourOn
                            }
                        // && currentMode == .light
                        Toggle("Paint", isOn: $isPainting)
                            .toggleStyle(PaintToggleStyle())
                            .foregroundColor(Color(red: r, green: g, blue: b))
//                            .onChange(of: cameraLocked) { newValue in
//                                controls.cameraLocked = cameraLocked
//                            }
                            .onChange(of: isPainting, perform: addMethodChanged)
                        // choose how to add/remove shapes to the physics environment
//                        Picker("AddMethod", selection: $addMethod) {
//                            Text("Add").tag(AddMethod.add)
//                            Text("Paint").tag(AddMethod.paint)
//                        }
//                        .onChange(of: addMethod, perform: addMethodChanged)
                    }
                    .padding([.bottom, .top], 2)
                    
                    // physics environment
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
//                            let height = geometry.size.height

                            // this view contains the physics (will letter box if smaller than view area reserved for physics)
                            // note: width is limited whether it is full frame or not
                            SpriteView(scene: scene)
                                .frame(width: width)
                                .onAppear{ self.storeGeometry(for: geometry) }
                        }
                    }
                    HStack {
                        HStack {
                            Text("Density")
                                .foregroundColor(Color(red: r, green: g, blue: b))
                            Slider(value: $density, in: 0...10, step: 1.0)
                                .padding([.horizontal])
                                .onChange(of: Float(density), perform: sliderDensityChanged)
                        }
                        .padding()
                        HStack {
                            Text("L Damp")
                                .foregroundColor(Color(red: r, green: g, blue: b))
                            Slider(value: $linearDamping, in: 0...1, step: 0.1)
                                .padding([.horizontal])
                                .onChange(of: Float(linearDamping), perform: sliderLinearDampingChanged)
                        }
                        .padding()
                    }
                    

                    HStack {
                        // shows different information here (user color settings, size settings)
                        Spacer()
                        Button(action: removeAll) {
                            Text("Clear All")
                        }
                        Spacer()
                        NavigationLink("Object Info", destination: ObjectSettings(height: $boxHeight, width: $boxWidth, r: $r, g: $g, b: $b))
                        Spacer()
                    }
                    
                }
            }
            .background(Color(red: r, green: g, blue: b, opacity: 0.25))
        }
    }
    
    private func storeGeometry(for geometry: GeometryProxy) {
        controls.screenWidth = geometry.size.width
        controls.screenHeight = geometry.size.height
    }
    
    private func sliderColorRChanged(to newValue: Double) {
        controls.r = newValue
    }
    
    private func sliderColorGChanged(to newValue: Double) {
        controls.g = newValue
    }
    
    private func sliderColorBChanged(to newValue: Double) {
        controls.b = newValue
    }
    
    private func sliderBoxHeightChanged(to newValue: Double) {
        controls.boxHeight = Double(newValue.rounded())
    }
    
    private func sliderBoxWidthChanged(to newValue: Double) {
        controls.boxWidth = Double(newValue.rounded())
    }
    
    private func shapeChanged(to newValue: Shape) {
        controls.selectedShape = newValue
    }
    
    private func addMethodChanged(to newValue: Bool) {
        controls.isPainting = newValue
//        controls.addMethod = newValue
    }
    
    private func removeAll() {
        controls.gameScene.removeAllChildren()
    }
    
    private func sliderDensityChanged(to newValue: Float) {
        controls.density = CGFloat(newValue)
    }
    
    private func sliderLinearDampingChanged(to newValue: Float) {
        controls.linearDamping = CGFloat(newValue)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
