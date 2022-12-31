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
    - combine drag and pour methods into dynamic action
        - if tapping a node, go into drag mode
        - if not tapping a node, go into drop/pour mode based on if tap or drag motion
        - have toggle mode for clearing nodes (on/off switch)
        - add paint mode switch
 
 Bugs
 - Adding a node can happen sometimes when dragging one (it appears watching others)
 - Drag method that checks for background layer makes drag very jittery, sometimes objects drop and return to mouse
 - Pour method does not work when there is a background node where touch starts
 - Rectangle height not working when clear & static, physics not applying at one point
 - Clear all can get stuck, when tapping screen after, clear catches up
 - Clear all removes camera node
 
 Feature ideas
 - Zoom in/out on a larger, boundry-defined scene
 - Adjust gravity based on tilt of phone
 - Persistance - save state whenever phone is turned
    - Allow user to set number of saves (just rolls and deletes old as new added)
    - Allow user to favorite saves so that they are never deleted
 - Add velocity direction to play with damping (applyForce & applyImpulse)
 - make new view, use pop up menu to put all controls in to free up screen
 
 Game ideas
 - Wrecking ball
 - Obstacle navigation
 - Boom blox
 - Gravity (simulate planets)
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
    // default box/color values - these are initialized in UIJoin (may not need values?)
    // TODO: these values are synced with default values in UIJoin - make one?
    // value may be needed at start (based on how initialization is handled)
    // Cannot use instance member 'controls' within property initializer; property initializers run before 'self' is available
    @State private var boxHeight = 6.0
    @State private var boxWidth = 6.0
    @State private var r =  0.62  // 0.34
    @State private var g = 0.53  // 0.74
    @State private var b = 1.0  // 0.7
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

    
    // TODO:  override the scene’s didChangeSize(_:) method, which is called whenever the scene changes size. When this method is called, you should update the scene’s contents to match the new size.
//    override func didChangeSize(_:) {
//
//    }
    
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
        
        // add camera node
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: scene.size.width / 2,
                                      y: scene.size.height / 2)
        scene.addChild(cameraNode)
        scene.camera = cameraNode
        
        // update shared references
        controls.gameScene = scene
        controls.camera = cameraNode
        return scene
    }
    
    // TODO: play with layout to optimize for screen space in the middle
    struct PourToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button(action: {
                    configuration.isOn.toggle()
                }, label: {
                    Image(systemName: configuration.isOn ?
                            "drop.fill" : "drop")
                        .renderingMode(.template)
                        .foregroundColor(configuration.isOn ? .red : .black)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
     
//                Spacer().frame(height: 20)
     
                Text(configuration.isOn ?
                        "on" :
                        "off")
//                    .italic()
                    .foregroundColor(.gray)
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
                        .foregroundColor(configuration.isOn ? .red : .black)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
     
//                Spacer().frame(height: 20)
     
                Text(configuration.isOn ?
                        "on" :
                        "off")
//                    .italic()
                    .foregroundColor(.gray)
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
                        .foregroundColor(configuration.isOn ? .red : .black)
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
     
//                Spacer().frame(height: 20)
     
                Text(configuration.isOn ?
                        "on" :
                        "off")
//                    .italic()
                    .foregroundColor(.gray)
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
                            Text("\(selectedShape.rawValue) size")
                            HStack {
                                Text("H")
                                Slider(value: $boxHeight, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxHeight, perform: sliderBoxHeightChanged)
                            }
                            HStack {
                                Text("W")
                                Slider(value: $boxWidth, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxWidth, perform: sliderBoxWidthChanged)
                            }
                        }
                        .padding()
                        VStack {
                            Text("Color")
                            VStack {
                                // TODO: see if you can caculate complimentary color to current and adjust RGB text to match
                                HStack {
                                    Text("R")
                                    Slider(value: $r, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: r, perform: sliderColorRChanged)
                                }
                                HStack {
                                    Text("G")
                                    Slider(value: $g, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: g, perform: sliderColorGChanged)
                                }
                                HStack {
                                    Text("B")
                                    Slider(value: $b, in: 0...1, step: 0.01)
                                        .padding([.horizontal])
                                        .onChange(of: b, perform: sliderColorBChanged)
                                }
                                
                            }
                            .padding()
                            .background(Color(red: r, green: g, blue: b))  // gives preview of chosen color
                        }
                        .padding()
                    }
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
//                            let height = geometry.size.height
                            
                            // this view contains the physics (will letter box if smaller than view area reserved for physics)
                            // note: width is limited whether it is full frame or not
                            SpriteView(scene: scene)
                                .frame(width: width)
//                                .ignoresSafeArea()
                                .onAppear{ self.storeGeometry(for: geometry) }
                        }
                    }
                    // choose how to add/remove shapes to the physics environment
                    Picker("AddMethod", selection: $addMethod) {
                        Text("Add").tag(AddMethod.add)
                        Text("Paint").tag(AddMethod.paint)
                    }
                    .onChange(of: addMethod, perform: addMethodChanged)
                    HStack {
                        HStack {
                            Text("Density")
                            Slider(value: $density, in: 0...10, step: 1.0)
                                .padding([.horizontal])
                                .onChange(of: Float(density), perform: sliderDensityChanged)
                        }
                        .padding()
                        HStack {
                            Text("L Damp")
                            Slider(value: $linearDamping, in: 0...1, step: 0.1)
                                .padding([.horizontal])
                                .onChange(of: Float(linearDamping), perform: sliderLinearDampingChanged)
                        }
                        .padding()
                    }
                    HStack {
                        Toggle("Clear", isOn: $removeOn)
                            .onChange(of: removeOn) { newValue in
                                controls.removeOn = removeOn
                            }
                            .toggleStyle(ClearToggleStyle())
                            .padding()
                        Toggle("Static", isOn: $staticNode)
                            .onChange(of: staticNode) { newValue in
                                controls.staticNode = staticNode
                            }
                            .toggleStyle(StaticToggleStyle())
                            .padding()
                        Toggle("", isOn: $pourOn)
                            .toggleStyle(PourToggleStyle())
                            .onChange(of: pourOn) { newValue in
                                controls.pourOn = pourOn
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
    
    private func addMethodChanged(to newValue: AddMethod) {
        controls.addMethod = newValue
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
