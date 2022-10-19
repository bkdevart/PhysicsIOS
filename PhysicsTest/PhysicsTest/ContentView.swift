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
class GameScene: SKScene {
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
        let box = SKSpriteNode(color: SKColor.red, size: CGSize(width: 120, height: 120))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 120))
        addChild(box)
    }
}


struct ContentView: View {
    /*
     May have to read https://github.com/joshuajhomann/SwiftUI-Spirograph to get combine to work with geometry reader to get proper scene.size set (hardcoded to iPhone 13 pro right now)
     */
    @State private var distance = 25.0
    @State private var maxHeight = 2532
    @State private var maxWidth = 1170
    
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
                    Slider(value: $distance, in: 1...150, step: 1)
                                    .padding([.horizontal, .bottom])
                }
                
            }
            
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
