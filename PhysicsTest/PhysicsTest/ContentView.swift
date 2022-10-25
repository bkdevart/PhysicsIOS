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

// using this to track box size and color selection across views
class UIJoin: ObservableObject {
    @Published var size = 120.0
    @Published var r = 0.34
    @Published var g = 0.74
    @Published var b = 0.7
    @Published var isBox = true

    static var shared = UIJoin()
}

class GameScene: SKScene {
    @ObservedObject var controls = UIJoin.shared
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    // TODO change this to touchesMoved
    /*
     https://mammothinteractive.com/touches-and-moving-sprites-in-xcode-spritekit-swift-crash-course-free-tutorial/
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // make box size between 40 and 240 (based on slider)
        // TODO: make this so user can choose height and width
        let boxWidth = Int(controls.size)
        let boxHeight = Int(controls.size)
        // make color betwen 0 and 1 (based on slider)
        let chosenColor: Color = Color(red: controls.r,
                                       green: controls.g,
                                       blue: controls.b)
        // add another shape as an option
        if (controls.isBox) {
            let box = SKSpriteNode(color: UIColor(chosenColor), size: CGSize(width: boxWidth, height: boxHeight))
            box.position = location
            // see if this causes gravity effect to take hold
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: boxWidth, height: boxHeight))
            addChild(box)
        } else {
            // TODO: can use this method to create more complicated shapes, and allow user to do so themselves
            let path = CGMutablePath()
            path.addArc(center: CGPoint.zero,
                        radius: controls.size / 2,
                        startAngle: 0,
                        endAngle: CGFloat.pi * 2,
                        clockwise: true)
            let ball = SKShapeNode(path: path)
            ball.fillColor = UIColor(chosenColor)
            ball.strokeColor = UIColor(chosenColor)
            ball.position = location
            ball.physicsBody = SKPhysicsBody(circleOfRadius: controls.size / 2)
            addChild(ball)
        }
        
        print("object height/width: \(boxWidth), r:  \(controls.r), g:  \(controls.g), b:  \(controls.b)")
    }
}


struct ContentView: View {
    // default box/color values - these are initialized in UIJoin (may not need values?)
    @State private var distance = 120.0
    @State private var r = 0.34
    @State private var g = 0.74
    @State private var b = 0.7
    @State private var isBox = true
    
    // using this to track box size and color selection as it changes
    let shapeConfig = UIJoin.shared
    
    /*
     May have to read https://github.com/joshuajhomann/SwiftUI-Spirograph to get combine to work with geometry reader to get proper scene.size set (hardcoded to iPhone 13 pro right now)
     */
    @State private var maxHeight = 2532
    @State private var maxWidth = 1170
    
    var scene: SKScene {
        let scene = GameScene()
        // TODO: temporary workaround until dynamic sizing performed
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
                    SpriteView(scene: scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    HStack {
                        VStack {
                            Text(isBox ? "Box Size" : "Circle Size")
                            Slider(value: $distance, in: 40...240, step: 1)
                                            .padding([.horizontal, .bottom])
                                            .onChange(of: distance, perform: sliderBoxSizeChanged)
                            // shows different information here (user color settings, size settings)
                            Toggle(isOn: $isBox) {
                                Text("Shape")
                            }
                            .onChange(of: isBox, perform: shapeChanged)
                            .padding()
                            NavigationLink("Object Info", destination: ObjectSettings(size: $distance, r: $r, g: $g, b: $b))
                        }
                        VStack {
                            Text("Color")
                            VStack {
                                HStack {
                                    Text("R")
                                    Slider(value: $r, in: 0...1, step: 0.01)
                                                    .padding([.horizontal, .bottom])
                                                    .onChange(of: r, perform: sliderColorRChanged)
                                }
                                HStack {
                                    Text("G")
                                    Slider(value: $g, in: 0...1, step: 0.01)
                                                    .padding([.horizontal, .bottom])
                                                    .onChange(of: g, perform: sliderColorGChanged)
                                }
                                HStack {
                                    Text("B")
                                    Slider(value: $b, in: 0...1, step: 0.01)
                                                    .padding([.horizontal, .bottom])
                                                    .onChange(of: b, perform: sliderColorBChanged)
                                }
                                
                            }
                            .padding()
                            .background(Color(red: r, green: g, blue: b))  // gives preview of chosen color
                        }
                        .padding()
                    }
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
    
    private func sliderBoxSizeChanged(to newValue: Double) {
        shapeConfig.size = Double(newValue.rounded())
    }
    
    private func shapeChanged(to newValue: Bool) {
        shapeConfig.isBox = newValue
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
