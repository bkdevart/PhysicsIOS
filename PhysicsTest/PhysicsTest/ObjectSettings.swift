//
//  ObjectSettings.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/25/22.
//

import SwiftUI

struct ObjectSettings: View {
    @Binding var height: Double
    @Binding var width: Double
    @Binding var r: Double
    @Binding var g: Double
    @Binding var b: Double
    
    var body: some View {
        Text("Current object values:")
        Text("Height: \(height)")
        Text("Width: \(width)")
        Text("R: \(r)")
        Text("G: \(g)")
        Text("B: \(b)")
    }
}

struct ObjectSettings_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettings(height: .constant(5.0), width: .constant(5.0), r: .constant(0.5), g: .constant(0.5), b: .constant(0.5))
    }
}
