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

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

// TODO: using this to track box size and color selection
class JointQ: ObservableObject {
  @Published var runner = false
  static var shared = JointQ()
}

class GameScene: SKScene {
    // TODO: using this to track box size and color selection
    @ObservedObject var kickoff = JointQ.shared
    
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
        // for fun, make box size random between 40 and 120
        let boxWidth = Int.random(in: 40..<240)
        let boxHeight = Int.random(in: 40..<240)
        // make color random as well
        let randomColor: Color = .random
        let box = SKSpriteNode(color: UIColor(randomColor), size: CGSize(width: boxWidth, height: boxHeight))
        box.position = location
        // see if this causes gravity effect to take hold
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: boxWidth, height: boxHeight))
        addChild(box)
    }
}


struct ContentView: View {
    /*
     May have to read https://github.com/joshuajhomann/SwiftUI-Spirograph to get combine to work with geometry reader to get proper scene.size set (hardcoded to iPhone 13 pro right now)
     */
    @State private var distance = 120.0
    @State private var color = 0.5
    @State private var maxHeight = 2532
    @State private var maxWidth = 1170
    
    // TODO: using this to track box size and color selection
    let door3 = JointQ.shared
    
        var scene: SKScene {
            let scene = GameScene()
            // temporary workaround until dynamic sizing performed

            scene.size = CGSize(width: maxWidth, height: maxHeight)
            scene.scaleMode = .fill
            return scene
        }

        var body: some View {
            Group {
                
                VStack {
                    SpriteView(scene: scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    Spacer()
                    Text("Box Size")
                    /*
                     https://stackoverflow.com/questions/66503964/passing-data-from-spritekit-scene-back-to-swiftui
                     or possibly Combine Framework
                     https://developer.algorand.org/tutorials/developing-2d-games-using-spritekit-and-swiftui-part-1/#4-spritekit-game-overview
                     or other methods
                     https://betterprogramming.pub/7-ways-to-link-swiftui-views-to-spritekit-scene-58180a57ab58
                     */
                    
                    Slider(value: $distance, in: 1...240, step: 1)
                                    .padding([.horizontal, .bottom])
                    Text("Color")
                    Slider(value: $color, in: 0...1, step: 0.01)
                                    .padding([.horizontal, .bottom])
                    // TODO: using this to track box size and color selection
                    Button {
                      door3.runner = true
                    } label: {
                      Text("jump")
                    }
                }
                
            }
            
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
