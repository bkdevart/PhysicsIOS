//
//  ObjectSettings.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/25/22.
//

import SwiftUI
import SpriteKit

// using this to track box size and color selection across views
class UIJoin: ObservableObject {
    @Published var r = 0.62  // 0.34
    @Published var g = 0.53  // 0.74
    @Published var b = 1.0  // 0.7
    @Published var selectedShape: Shape = .rectangle
    @Published var screenWidth: CGFloat = 428.0
    @Published var screenHeight: CGFloat = 313.97// 313.97  // set to same as width to preserve square?
    @Published var boxHeight = 5.0
    @Published var boxWidth = 5.0
    @Published var addMethod: AddMethod = .add
    @Published var selectedNode = SKNode()
    @Published var selectedNodes = [SKNode]()
    @Published var removeOn = false
    @Published var paintLayer = 0
    @Published var pourOn = false
    
    // capture state of entire scene
    @Published var gameScene = SKScene()
    
    // TODO: capture SwiftUI views in variable here (if possible)
//    @Published var swiftUIViews = ContentView()

    static var shared = UIJoin()
}


func renderNode(location: CGPoint, hasPhysics: Bool=false, zPosition: Int=0) -> SKNode {
//        let location = touch.location(in: self)
    @ObservedObject var controls = UIJoin.shared
    
    // user can choose height and width
    let boxWidth = Int((controls.boxWidth / 100.0) * Double(controls.screenWidth))
    let boxHeight = Int((controls.boxHeight / 100.0) * Double(controls.screenHeight))
    // each color betwen 0 and 1 (based on slider)
    let chosenColor: Color = Color(red: controls.r,
                                   green: controls.g,
                                   blue: controls.b)
    
    controls.selectedNode = SKNode()
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
        box.zPosition = CGFloat(zPosition)
        if hasPhysics {
            box.physicsBody = SKPhysicsBody(polygonFrom: path)
        }
        return box

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
        ball.zPosition = CGFloat(zPosition)
        if hasPhysics {
            ball.physicsBody = SKPhysicsBody(polygonFrom: path)
        }
        return ball

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
        triangle.zPosition = CGFloat(zPosition)
        if hasPhysics {
            triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
        }
        return triangle
    }
}


// this view is used by info screen to show object info
struct ObjectSettings: View {
    @Binding var height: Double
    @Binding var width: Double
    @Binding var r: Double
    @Binding var g: Double
    @Binding var b: Double
    
    
    @ObservedObject var controls = UIJoin.shared
    
    var body: some View {
        Text("Current object values:")
        Text("Object Height: \(height)")
        Text("Object Width: \(width)")
        Text("Red: \(r)")
        Text("Green: \(g)")
        Text("Blue: \(b)")
        Text("Screen Height: \(controls.screenHeight)")
        Text("Screen Height: \(controls.screenWidth)")
    }
}
