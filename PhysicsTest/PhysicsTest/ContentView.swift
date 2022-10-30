//
//  ContentView.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/18/22.
/*
 Based on code from:
 https://betterprogramming.pub/build-swiftui-games-using-spritekit-deb069535765
 */
//

import SwiftUI
import CoreData
import SpriteKit
//import UIKit

enum Shape: String, CaseIterable, Identifiable {
    case rectangle, circle, triangle
    var id: Self { self }
}

// using this to track box size and color selection across views
class UIJoin: ObservableObject {
    @Published var r = 0.34
    @Published var g = 0.74
    @Published var b = 0.7
    @Published var shape = "rectangle"
    @Published var selectedShape: Shape = .rectangle
    @Published var screenWidth = 428
    @Published var screenHeight = 478
    @Published var boxHeight = 5.0
    @Published var boxWidth = 5.0

    static var shared = UIJoin()
}

class GameScene: SKScene {
    
    
    @ObservedObject var controls = UIJoin.shared
//    var touchLocation = CGPoint?()
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    // TODO: add multiple drop methods
    /*
     1. tap and drop (original)
     2. touch and hold (pour shapes)
     3. touch once to place, then drag and drop when let go
     */

    /*
     https://mammothinteractive.com/touches-and-moving-sprites-in-xcode-spritekit-swift-crash-course-free-tutorial/
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
                let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
                let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
                print("Box height: \(boxHeight)")
                print("Box width: \(boxWidth)")
                // each color betwen 0 and 1 (based on slider)
                let chosenColor: Color = Color(red: controls.r,
                                               green: controls.g,
                                               blue: controls.b)
                // basic shapes
                print(controls.shape)
                switch controls.shape {
                case "rectangle":
                    print("Rectangle")
                    let path = CGMutablePath()
                    let box_half = Int(boxWidth) / 2
                    path.move(to: CGPoint(x: -box_half, y: Int(boxHeight)))  // upper left corner
                    path.addLine(to: CGPoint(x: box_half, y: Int(boxHeight)))  // upper right corner
                    path.addLine(to: CGPoint(x: box_half, y: 0)) // bottom right corner
                    path.addLine(to: CGPoint(x: -box_half, y: 0))  // bottom left corner
                    let box = SKShapeNode(path: path)
                    box.fillColor = UIColor(chosenColor)
                    box.strokeColor = UIColor(chosenColor)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(polygonFrom: path)
                    // TODO: figure out what addChild is being called with
                    addChild(box)
                // TODO: can use path method to create more complicated shapes, and allow user to do so themselves
                case "circle":
                    print("Circle")
                    let path = CGMutablePath()
                    path.addArc(center: CGPoint.zero,
                                radius: CGFloat(Int(boxWidth) / 2),
                                startAngle: 0,
                                endAngle: CGFloat.pi * 2,
                                clockwise: true)
                    let ball = SKShapeNode(path: path)
                    ball.fillColor = UIColor(chosenColor)
                    ball.strokeColor = UIColor(chosenColor)
                    ball.position = location
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(Int(boxWidth) / 2))
                    addChild(ball)
                case "triangle":
                    print("Triangle")
                    let path = CGMutablePath()
                    // TODO: try two side lengths and an angle, infer 3rd size
                    // center shape around x=0
                    let triangle_half = Int(boxWidth) / 2
                    path.move(to: CGPoint(x: 0, y: Int((0.5 * (3.0.squareRoot() * Double(boxWidth))))))  // triangle top
                    path.addLine(to: CGPoint(x: triangle_half, y: 0))  // bottom right corner
                    path.addLine(to: CGPoint(x: -triangle_half, y: 0))  // bottom left corner
                    path.addLine(to: CGPoint(x: 0, y: Int((0.5 * (3.0.squareRoot() * Double(boxWidth))))))  // back to triangle top (not needed)
                    let triangle = SKShapeNode(path: path)
                    triangle.fillColor = UIColor(chosenColor)
                    triangle.strokeColor = UIColor(chosenColor)
                    triangle.position = location
                    triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
                    // TODO: figure out what addChild is being called with
                    addChild(triangle)
                default:
                    print("You failed")
                }
        
                print("object height/width: \(boxWidth), r:  \(controls.r), g:  \(controls.g), b:  \(controls.b)")
            }
        }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        // TODO: make this so user can choose height and width
//        let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
//        let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
//        print("Box height: \(boxHeight)")
//        print("Box width: \(boxWidth)")
//        // each color betwen 0 and 1 (based on slider)
//        let chosenColor: Color = Color(red: controls.r,
//                                       green: controls.g,
//                                       blue: controls.b)
//        // basic shapes
//        print(controls.shape)
//        switch controls.shape {
//        case "rectangle":
//            print("Rectangle")
//            let path = CGMutablePath()
//            let box_half = Int(boxWidth) / 2
//            path.move(to: CGPoint(x: -box_half, y: Int(boxHeight)))  // upper left corner
//            path.addLine(to: CGPoint(x: box_half, y: Int(boxHeight)))  // upper right corner
//            path.addLine(to: CGPoint(x: box_half, y: 0)) // bottom right corner
//            path.addLine(to: CGPoint(x: -box_half, y: 0))  // bottom left corner
//            let box = SKShapeNode(path: path)
//            box.fillColor = UIColor(chosenColor)
//            box.strokeColor = UIColor(chosenColor)
//            box.position = location
//            box.physicsBody = SKPhysicsBody(polygonFrom: path)
//            // TODO: figure out what addChild is being called with
//            addChild(box)
//        // TODO: can use path method to create more complicated shapes, and allow user to do so themselves
//        case "circle":
//            print("Circle")
//            let path = CGMutablePath()
//            path.addArc(center: CGPoint.zero,
//                        radius: CGFloat(Int(boxWidth) / 2),
//                        startAngle: 0,
//                        endAngle: CGFloat.pi * 2,
//                        clockwise: true)
//            let ball = SKShapeNode(path: path)
//            ball.fillColor = UIColor(chosenColor)
//            ball.strokeColor = UIColor(chosenColor)
//            ball.position = location
//            ball.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(Int(boxWidth) / 2))
//            addChild(ball)
//        case "triangle":
//            print("Triangle")
//            let path = CGMutablePath()
//            // TODO: try two side lengths and an angle, infer 3rd size
//            // center shape around x=0
//            let triangle_half = Int(boxWidth) / 2
//            path.move(to: CGPoint(x: 0, y: Int((0.5 * (3.0.squareRoot() * Double(boxWidth))))))  // triangle top
//            path.addLine(to: CGPoint(x: triangle_half, y: 0))  // bottom right corner
//            path.addLine(to: CGPoint(x: -triangle_half, y: 0))  // bottom left corner
//            path.addLine(to: CGPoint(x: 0, y: Int((0.5 * (3.0.squareRoot() * Double(boxWidth))))))  // back to triangle top (not needed)
//            let triangle = SKShapeNode(path: path)
//            triangle.fillColor = UIColor(chosenColor)
//            triangle.strokeColor = UIColor(chosenColor)
//            triangle.position = location
//            triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
//            // TODO: figure out what addChild is being called with
//            addChild(triangle)
//        default:
//            print("You failed")
//        }
//
//        print("object height/width: \(boxWidth), r:  \(controls.r), g:  \(controls.g), b:  \(controls.b)")
//    }
}


struct ContentView: View {
    // default box/color values - these are initialized in UIJoin (may not need values?)
    @State private var boxHeight = 5.0
    @State private var boxWidth = 5.0
    @State private var r = 0.34
    @State private var g = 0.74
    @State private var b = 0.7
    
    // using this to track box size and color selection as it changes
    let shapeConfig = UIJoin.shared
    
    /*
     May have to read https://github.com/joshuajhomann/SwiftUI-Spirograph to get combine to work with geometry reader to get proper scene.size set (hardcoded to iPhone 13 pro right now)
     */
    

//    var maxHeight = 2532
//    var maxWidth = 1170

    // houses shape picker selection
    @State private var selectedShape: Shape = .rectangle
    
    var scene: SKScene {
        let scene = GameScene()
        // TODO: make sure dynamic sizing is working properly
        let maxHeight = shapeConfig.screenHeight  // 2532
        let maxWidth = shapeConfig.screenWidth  // 1170
        scene.size = CGSize(width: maxWidth, height: maxHeight)
        scene.scaleMode = .fill
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
                        .onChange(of: selectedShape.rawValue, perform: shapeChanged)
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
                
                GeometryReader { geometry in
                    let width = geometry.size.width
//                    let height = geometry.size.height
                    
                    // note: making the scene square allows for rendering using square ratios
                    SpriteView(scene: scene)
                        .frame(maxWidth: width, maxHeight: width)  // height
                        .ignoresSafeArea()
                    //            shapeConfig.screenWidth = Int(width)
                    //            shapeConfig.screenHeight = Int(height)
                }
                // shows different information here (user color settings, size settings)
                NavigationLink("Object Info", destination: ObjectSettings(height: $boxHeight, width: $boxWidth, r: $r, g: $g, b: $b))
                Spacer()
            }
        }
    }
}
    
    
    private func sliderColorRChanged(to newValue: Double) {
        shapeConfig.r = newValue
    }
    
    private func sliderColorGChanged(to newValue: Double) {
        shapeConfig.g = newValue
    }
    
    private func sliderColorBChanged(to newValue: Double) {
        shapeConfig.b = newValue
    }
    
    private func sliderBoxHeightChanged(to newValue: Double) {
        shapeConfig.boxHeight = Double(newValue.rounded())
    }
    
    private func sliderBoxWidthChanged(to newValue: Double) {
        shapeConfig.boxWidth = Double(newValue.rounded())
    }
    
    private func shapeChanged(to newValue: String) {
        shapeConfig.shape = newValue
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
