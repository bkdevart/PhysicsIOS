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
 
 Icon
 - Green/Purple, redish-light-green (current color in simulator), blue/yellow
 
 Interface ideas
 - anything delightful
 - create settings button to allow for different theme choices (complementary, etc)
 
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

struct ContentView: View {
    @Environment(\.colorScheme) var currentMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass  // to get screenSize (iPad or iPhone)
    
    @State private var boxHeight = 6.0
    @State private var boxWidth = 6.0
    @State private var sceneHeight = 500
    @State private var density = 1.0  // 1.0
    @State private var staticNode = false
    @State private var linearDamping = 0.1
    @State private var letterText = "B"
    @State private var letterFont = "Menlo"
    
    @AppStorage("LastRed") private var lastRed = 0.0
    @AppStorage("LastGreen") private var lastGreen = 0.43
    @AppStorage("LastBlue") private var lastBlue = 0.83
    
    // using this to track box size and color selection as it changes
    let controls = UIJoin.shared

    // houses shape picker selection
    @State private var selectedShape: Shape = .rectangle
    @State public var removeOn = false
    @State public var pourOn = false
    @State public var isPainting = false
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
        scene.scaleMode = .aspectFit
        scene.view?.showsDrawCount = true
        // making complementary color of chosen object color
        scene.backgroundColor = UIColor(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), alpha: 0.5)
        
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
    
    struct SliderView3: View {
        @Binding var value: Double
        
        @State var lastCoordinateValue: CGFloat = 0.0
        var sliderRange: ClosedRange<Double> = 1...100
        var thumbColor: Color = .yellow
        var minTrackColor: Color = .blue
        var maxTrackColor: Color = .gray
        
        var body: some View {
            GeometryReader { gr in
                // TODO: may need to tweak these (hard to hit targets)
                let thumbHeight = gr.size.height * 1.1
                let thumbWidth = gr.size.width * 0.03  // make this larger and see if it helps orig val: 0.03, 0.1 has bad look
                let radius = gr.size.height * 0.5
                let minValue = gr.size.width * 0.015
                let maxValue = (gr.size.width * 0.98) - thumbWidth
                
                let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
                let lower = sliderRange.lowerBound
                
                // TODO: look into pulling this from elsewhere (can't get user defaults from here)
//                let sliderVal = self.value
                let sliderVal = (self.value - lower) * scaleFactor + minValue
                
                ZStack {
                    Rectangle()
                        .foregroundColor(maxTrackColor)
                        .frame(width: gr.size.width, height: gr.size.height * 0.95)
                        .clipShape(RoundedRectangle(cornerRadius: radius))
                    HStack {
                        Rectangle()
                            .foregroundColor(minTrackColor)
                        // Invalid frame dimension (negative or non-finite).
                        .frame(width: sliderVal, height: gr.size.height * 0.95)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    HStack {
                        RoundedRectangle(cornerRadius: radius)
                            .foregroundColor(thumbColor)
                            .frame(width: thumbWidth, height: thumbHeight)
                            .offset(x: sliderVal)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { v in
                                        if (abs(v.translation.width) < 0.1) {
                                            self.lastCoordinateValue = sliderVal
                                        }
                                        if v.translation.width > 0 {
                                            let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minValue) / scaleFactor)  + lower
                                        } else {
                                            let nextCoordinateValue = max(minValue, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minValue) / scaleFactor) + lower
                                        }
                                   }
                            )
                        Spacer()
                    }
                }
            }
        }
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
                        .font(.system(size: 50))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // this is where the views are drawn (iPhone and iPad supported)
    @ViewBuilder
    var body: some View {
        if horizontalSizeClass == .compact {
            // original iOS view
            NavigationView {
                Group {
                    VStack {
                        // LayoutAndGeometry from 100 days of swiftui could be helpful
                        // Shape choice and height/width selection
                        HStack {
                            VStack {
                                VStack {
                                    Picker("Shape", selection: $selectedShape) {
                                        Text("Rectangle").tag(Shape.rectangle)
                                        Text("Circle").tag(Shape.circle)
                                        Text("Triangle").tag(Shape.triangle)
                                        Text("Text").tag(Shape.text)
                                        Text("Data").tag(Shape.data)
                                    }
                                    .onChange(of: selectedShape, perform: shapeChanged)
                                 
                                    // Baskerville, Chalkduster, Courier, Didot, Menlo
                                    Picker("Font", selection: $letterFont) {
                                        Text("Baskerville").tag("Baskerville")
                                        Text("Chalkduster").tag("Chalkduster")
                                        Text("Courier").tag("Courier")
                                        Text("Didot").tag("Didot")
                                        Text("Menlo").tag("Menlo")
                                    }
                                    .onChange(of: letterFont, perform: fontChanged)
                                }
                                
                                HStack {
                                    Text("H")
                                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                    Slider(value: $boxHeight, in: 1...100, step: 1)
                                        .padding([.horizontal])
                                        .onChange(of: boxHeight, perform: sliderBoxHeightChanged)
                                }
                                HStack {
                                    Text("W")
                                        .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                    Slider(value: $boxWidth, in: 1...100, step: 1)
                                        .padding([.horizontal])
                                        .onChange(of: boxWidth, perform: sliderBoxWidthChanged)
                                }
                            }
                            .padding()
                            // RGB color selection
                            VStack {
                                VStack {
                                    // TODO: see if you can caculate complimentary color to current and adjust RGB text to match
                                    // red selector
                                    VStack(spacing:0) {
                                        SliderView3(value: $lastRed,
                                                    sliderRange: 0...1,
                                                    thumbColor: .red,
                                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                        )
                                        .frame(height:30)
                                        .onChange(of: lastRed, perform: sliderColorRChanged)
                                    }
                                    // green selector
                                    VStack(spacing:0) {
                                        SliderView3(value: $lastGreen,
                                                    sliderRange: 0...1,
                                                    thumbColor: .green,
                                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                        )
                                        .frame(height:30)
                                        .onChange(of: lastGreen, perform: sliderColorGChanged)
                                    }
                                    // blue selector
                                    VStack(spacing:0) {
                                        SliderView3(value: $lastBlue,
                                                    sliderRange: 0...1,
                                                    thumbColor: .blue,
                                                    minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                    maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                        )
                                        .frame(height:30)
                                        .onChange(of: lastBlue, perform: sliderColorBChanged)
                                    }
                                }
                                .padding()
                                .background(Color(red: lastRed, green: lastGreen, blue: lastBlue))  // gives preview of chosen color
                                .cornerRadius(20)
                            }
                            .padding()
                        }
                        
                        // Toggle buttons
                        HStack {
                            TextField("B", text: $letterText)
                                .frame(width: 20)
                                .onSubmit({
                                    controls.letterText = letterText
                                })
                            // choose how to add/remove shapes to the physics environment
                            // && currentMode == .light
                            Toggle("Paint", isOn: $isPainting)
                                .toggleStyle(PaintToggleStyle())
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                .onChange(of: isPainting, perform: addMethodChanged)
                            Toggle("Static", isOn: $staticNode)
                                .onChange(of: staticNode) { newValue in
                                    controls.staticNode = staticNode
                                }
                                .toggleStyle(StaticToggleStyle())
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                            Toggle("Pour", isOn: $pourOn)
                                .toggleStyle(PourToggleStyle())
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                .onChange(of: pourOn) { newValue in
                                    controls.pourOn = pourOn
                                }
                            Toggle("Clear", isOn: $removeOn)
                                .onChange(of: removeOn) { newValue in
                                    controls.removeOn = removeOn
                                }
                                .toggleStyle(ClearToggleStyle())
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                        }
                        .padding([.bottom, .top], 2)
                        .frame(maxHeight: 52, alignment: .center)
                        
                        // physics environment
                        HStack {
                            GeometryReader { geometry in
                                let width = geometry.size.width
                                SpriteView(scene: scene)
                                    .frame(width: width)
                                    .onAppear{ self.storeGeometry(for: geometry) }
                            }
                        }
                        
                        // physics sliders
                        HStack {
                            HStack {
                                Text("Density")
                                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                Slider(value: $density, in: 0...10, step: 1.0)
                                    .padding([.horizontal])
                                    .onChange(of: Float(density), perform: sliderDensityChanged)
                            }
                            .padding()
                            HStack {
                                Text("L Damp")
                                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                Slider(value: $linearDamping, in: 0...1, step: 0.1)
                                    .padding([.horizontal])
                                    .onChange(of: Float(linearDamping), perform: sliderLinearDampingChanged)
                            }
                            .padding()
                        }
                        
                        // clear/object info buttons
                        HStack {
                            Spacer()
                            Button(action: removeAll) {
                                Text("Clear All")
                            }
                            Spacer()
                            // shows different information here (user color settings, size settings)
                            NavigationLink("Object Info", destination: ObjectSettings())
                            Spacer()
                        }
                    }
                }
                .background(Color(red: lastRed, green: lastGreen, blue: lastBlue, opacity: 0.25))
            }
        } else {
            // ipad view
            Group {
                VStack {
                    // TODO: find a way to use Geometry Reader to dynamically fit and keep correct ratio for boxes
                    // LayoutAndGeometry from 100 days of swiftui could be helpful
                    // Shape choice and height/width selection
                    HStack {
                        VStack {
                            Picker("Shape", selection: $selectedShape) {
                                Text("Rectangle").tag(Shape.rectangle)
                                Text("Circle").tag(Shape.circle)
                                Text("Triangle").tag(Shape.triangle)
                            }
                            .onChange(of: selectedShape, perform: shapeChanged)
                            
                            HStack {
                                Text("H")
                                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                Slider(value: $boxHeight, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxHeight, perform: sliderBoxHeightChanged)
                            }
                            HStack {
                                Text("W")
                                    .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                                Slider(value: $boxWidth, in: 1...100, step: 1)
                                    .padding([.horizontal])
                                    .onChange(of: boxWidth, perform: sliderBoxWidthChanged)
                            }
                        }
                        .padding()
                        // RGB color selection
                        VStack {
                            VStack {
                                // TODO: see if you can caculate complimentary color to current and adjust RGB text to match
                                // red selector
                                VStack(spacing:0) {
                                    SliderView3(value: $lastRed,
                                                sliderRange: 0...1,
                                                thumbColor: .red,
                                                minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                    )
                                    .frame(height:30)
                                    .onChange(of: lastRed, perform: sliderColorRChanged)
                                }
                                // green selector
                                VStack(spacing:0) {
                                    SliderView3(value: $lastGreen,
                                                sliderRange: 0...1,
                                                thumbColor: .green,
                                                minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                    )
                                    .frame(height:30)
                                    .onChange(of: lastGreen, perform: sliderColorGChanged)
                                }
                                // blue selector
                                VStack(spacing:0) {
                                    SliderView3(value: $lastBlue,
                                                sliderRange: 0...1,
                                                thumbColor: .blue,
                                                minTrackColor: Color(red: abs(lastRed - 1.0), green: abs(lastGreen - 1.0), blue: abs(lastBlue - 1.0), opacity: 1.0),
                                                maxTrackColor: Color(red: (lastRed), green: (lastGreen), blue: (lastBlue), opacity: 1.0)
                                    )
                                    .frame(height:30)
                                    .onChange(of: lastBlue, perform: sliderColorBChanged)
                                }
                            }
                            .padding()
                            .background(Color(red: lastRed, green: lastGreen, blue: lastBlue))  // gives preview of chosen color
                            .cornerRadius(20)
                        }
                        .padding()
                    }
                    
                    // Toggle buttons
                    HStack {
                        // choose how to add/remove shapes to the physics environment
                        // && currentMode == .light
                        Toggle("Paint", isOn: $isPainting)
                            .toggleStyle(PaintToggleStyle())
                            .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                            .onChange(of: isPainting, perform: addMethodChanged)
                        Toggle("Static", isOn: $staticNode)
                            .onChange(of: staticNode) { newValue in
                                controls.staticNode = staticNode
                            }
                            .toggleStyle(StaticToggleStyle())
                            .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                        Toggle("Pour", isOn: $pourOn)
                            .toggleStyle(PourToggleStyle())
                            .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                            .onChange(of: pourOn) { newValue in
                                controls.pourOn = pourOn
                            }
                        Toggle("Clear", isOn: $removeOn)
                            .onChange(of: removeOn) { newValue in
                                controls.removeOn = removeOn
                            }
                            .toggleStyle(ClearToggleStyle())
                            .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                    }
                    .padding([.bottom, .top], 2)
                    .frame(maxHeight: 52, alignment: .center)
                    
                    // physics environment
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            SpriteView(scene: scene)
                                .frame(width: width)
                                .onAppear{ self.storeGeometry(for: geometry) }
                        }
                    }
                    
                    // physics sliders
                    HStack {
                        HStack {
                            Text("Density")
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                            Slider(value: $density, in: 0...10, step: 1.0)
                                .padding([.horizontal])
                                .onChange(of: Float(density), perform: sliderDensityChanged)
                        }
                        .padding()
                        HStack {
                            Text("L Damp")
                                .foregroundColor(Color(red: lastRed, green: lastGreen, blue: lastBlue))
                            Slider(value: $linearDamping, in: 0...1, step: 0.1)
                                .padding([.horizontal])
                                .onChange(of: Float(linearDamping), perform: sliderLinearDampingChanged)
                        }
                        .padding()
                    }
                    
                    // clear/object info buttons
                    HStack {
                        Spacer()
                        Button(action: removeAll) {
                            Text("Clear All")
                        }
                        Spacer()
                        // shows different information here (user color settings, size settings)
                        NavigationLink("Object Info", destination: ObjectSettings())
                        Spacer()
                    }
                }
            }
            .background(Color(red: lastRed, green: lastGreen, blue: lastBlue, opacity: 0.25))
        }
    }
    
    private func storeGeometry(for geometry: GeometryProxy) {
        controls.screenWidth = geometry.size.width
        controls.screenHeight = geometry.size.height
    }
    
    private func sliderColorRChanged(to newValue: Double) {
        lastRed = newValue
    }
    
    private func sliderColorGChanged(to newValue: Double) {
        // save user defaults
        lastGreen = newValue
    }
    
    private func sliderColorBChanged(to newValue: Double) {
        lastBlue = newValue
    }
    
    private func sliderBoxHeightChanged(to newValue: Double) {
        controls.boxHeight = Double(newValue.rounded())
    }
    
    private func sliderBoxWidthChanged(to newValue: Double) {
        controls.boxWidth = Double(newValue.rounded())
    }
    
    private func shapeChanged(to newValue: Shape) {
        controls.selectedShape = newValue
        // TODO: if data, load data
        if newValue == .data {
            controls.loadData()
        }
    }
    
    private func fontChanged(to newValue: String) {
        controls.letterFont = newValue
//        print(newValue)
    }
    
    private func addMethodChanged(to newValue: Bool) {
        controls.isPainting = newValue
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
