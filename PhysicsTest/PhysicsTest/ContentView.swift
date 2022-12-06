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
 - Drag method that checks for background layer makes drag very jittery, sometimes objects drop and return to mouse
 
 Game ideas
 - Wrecking ball
 - Obstacle navigation
 - Boom blox
 */
//

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
    @State private var boxHeight = 5.0
    @State private var boxWidth = 5.0
    @State private var r = 0.34
    @State private var g = 0.74
    @State private var b = 0.7
    
    
    // using this to track box size and color selection as it changes
    let controls = UIJoin.shared
    
    /*
     May have to read https://github.com/joshuajhomann/SwiftUI-Spirograph to get combine to work with geometry reader to get proper scene.size set (hardcoded to iPhone 13 pro right now)
     */

    // houses shape picker selection
    @State private var selectedShape: Shape = .rectangle
    @State private var addMethod: AddMethod = .add
    @State public var removeOn = false
    @State public var pourOn = false

    
    var scene: SKScene {
        let scene = GameScene()
        // TODO: make sure dynamic sizing is working properly
        let maxHeight = controls.screenHeight  // 2532
        let maxWidth = controls.screenWidth  // 1170
        scene.size = CGSize(width: maxWidth, height: maxHeight)
        scene.scaleMode = .fill
        // store in observable object
        controls.gameScene = scene
        return scene
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
                    // TODO: figure out how to get a reference to this object
                    GeometryReader { geometry in
                        let width = geometry.size.width
    //                    let height = geometry.size.height
                        
                        // note: making the scene square allows for rendering using square ratios
                        SpriteView(scene: scene)
                            .frame(maxWidth: width, maxHeight: width)  // makes things square
                            .ignoresSafeArea()
                    }
                    // choose how to add/remove shapes to the physics environment
                    Picker("AddMethod", selection: $addMethod) {
                        Text("Add").tag(AddMethod.add)
                        Text("Paint").tag(AddMethod.paint)
                    }
                    .onChange(of: addMethod, perform: addMethodChanged)
                    Toggle("Remove", isOn: $removeOn)
                        .onChange(of: removeOn) { newValue in
                            controls.removeOn = removeOn
                        }
                        .padding()
                    Toggle("Pour", isOn: $pourOn)
                        .onChange(of: pourOn) { newValue in
                            controls.pourOn = pourOn
                        }
                        .padding()
                    HStack {
                        // shows different information here (user color settings, size settings)
                        Spacer()
                        Button(action: removeAll) {
                            Text("Remove All")
                        }
                        Spacer()
                        NavigationLink("Object Info", destination: ObjectSettings(height: $boxHeight, width: $boxWidth, r: $r, g: $g, b: $b))
                        Spacer()
                    }
                    
                }
            }
        }
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
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
