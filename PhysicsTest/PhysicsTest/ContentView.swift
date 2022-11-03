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
 - Remove All button doesn't seem to work as intended (once switching to a new shape or add method it fails to work)
 
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
    case pour, drag, paint, clear
    var id: Self { self }
}

// using this to track box size and color selection across views
class UIJoin: ObservableObject {
    @Published var r = 0.34
    @Published var g = 0.74
    @Published var b = 0.7
    @Published var selectedShape: Shape = .rectangle
    @Published var screenWidth = 428
    @Published var screenHeight = 478  // TODO: set to same as height to preserve square?
    @Published var boxHeight = 5.0
    @Published var boxWidth = 5.0
    @Published var addMethod: AddMethod = .pour
//    @Published var childNumber = 0
//    @Published var children = [SKShapeNode]()
    @Published var selectedNode = SKNode()
    @Published var selectedNodes = [SKNode]()
    @Published var removeOn = false
    
    // can you capture game scene here?
    @Published var gameScene = SKScene()

    static var shared = UIJoin()
}

class GameScene: SKScene {
    
    
    @ObservedObject var controls = UIJoin.shared
    
    // when the scene is presented by the view, didMove activates and triggers the physics engine environment
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }


    /*
     https://mammothinteractive.com/touches-and-moving-sprites-in-xcode-spritekit-swift-crash-course-free-tutorial/
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch controls.addMethod {
        case .clear:
            print("Will think about this clear method dragging finger")
//            removeAllChildren()
        case .drag:
            for touch in touches {
                let location = touch.location(in: self)
                // make sure selectedNode exists (may be causing crash)
                // 1 - check that selectedNode is not null
                if controls.selectedNodes.count > 0 {
                    controls.selectedNode.position = location
                }
                // 2 - select scene camera otherwise?  this would be good way to begin making playground more defined
                
            }
        case .pour:
            for touch in touches{
                let location = touch.location(in: self)
                let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
                let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
                // each color betwen 0 and 1 (based on slider)
                let chosenColor: Color = Color(red: controls.r,
                                               green: controls.g,
                                               blue: controls.b)
                // basic shapes
                switch controls.selectedShape {
                case .rectangle:
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
                    addChild(box)
//                    controls.children.append(box)
                case .circle:
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
//                    controls.children.append(ball)
                case .triangle:
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
                    addChild(triangle)
//                    controls.children.append(triangle)
                }
            }
        case .paint:
            for touch in touches{
                let location = touch.location(in: self)
                let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
                let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
                // each color betwen 0 and 1 (based on slider)
                let chosenColor: Color = Color(red: controls.r,
                                               green: controls.g,
                                               blue: controls.b)
                // basic shapes
                switch controls.selectedShape {
                case .rectangle:
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
//                    box.physicsBody = SKPhysicsBody(polygonFrom: path)
                    addChild(box)
//                    controls.children.append(box)
                case .circle:
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
//                    ball.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(Int(boxWidth) / 2))
                    addChild(ball)
//                    controls.children.append(ball)
                case .triangle:
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
//                    triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
                    addChild(triangle)
//                    controls.children.append(triangle)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // user can choose height and width
        let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
        let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
        // each color betwen 0 and 1 (based on slider)
        let chosenColor: Color = Color(red: controls.r,
                                       green: controls.g,
                                       blue: controls.b)
        
        switch controls.addMethod {
        case .clear:
            // select node and delete only that one
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                controls.selectedNode = touchedNodes[0]
            } else {
                controls.selectedNode = SKNode()
            }
            controls.selectedNode.removeFromParent()
        case .drag:
            let touchedNodes = nodes(at: location)
            controls.selectedNodes = touchedNodes
            // will crash here if no nodes are touched
            if touchedNodes.count > 0 {
                controls.selectedNode = touchedNodes[0]
            } else {
                controls.selectedNode = SKNode()
            }
        case .pour:
            // render shapes continuously while user drags finger
            switch controls.selectedShape {
            case .rectangle:
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
                addChild(box)
//                controls.children.append(box)
            case .circle:
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
//                controls.children.append(ball)
            case .triangle:
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
                addChild(triangle)
//                controls.children.append(triangle)
            }
        case .paint:
            // render shape when user taps here, don't add gravity until user drags and releases (touchesMoved())
            switch controls.selectedShape {
            case .rectangle:
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
                //                box.physicsBody = SKPhysicsBody(polygonFrom: path)
                addChild(box)
//                controls.children.append(box)
            case .circle:
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
//                ball.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(Int(boxWidth) / 2))
                addChild(ball)
//                controls.children.append(ball)
            case .triangle:
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
//                triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
                addChild(triangle)
//                controls.children.append(triangle)
            }
        }
    }
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
    @State private var addMethod: AddMethod = .pour
//    @State private var removeOn: Bool = false
    @State var removeOn: Bool = false {
            didSet {
                controls.removeOn = removeOn
            }
        }
    
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
                // choose how to add shapes to the physics environment
                Toggle("Remove", isOn: $removeOn)
//                    .onUpdate({controls.removeOn = removeOn})
//                    .onChange(of: removeOn, perform: updateRemoveToggle)
                Picker("AddMethod", selection: $addMethod) {
                    Text("Pour").tag(AddMethod.pour)
                    Text("Drag").tag(AddMethod.drag)
                    Text("Remove").tag(AddMethod.clear)
                    Text("Paint").tag(AddMethod.paint)
                }
                .onChange(of: addMethod, perform: addMethodChanged)
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
    
    private func updateRemoveToggle() {
        controls.removeOn = removeOn
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
