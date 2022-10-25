//
//  ObjectSettings.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/25/22.
//

import SwiftUI

struct ObjectSettings: View {
    @Binding var size: Double
    @Binding var r: Double
    @Binding var g: Double
    @Binding var b: Double
    
    var body: some View {
        Text("Current object values:")
        Text("Size: \(size)")
        Text("R: \(r)")
        Text("G: \(g)")
        Text("B: \(b)")
    }
}

struct ObjectSettings_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettings(size: .constant(120.0), r: .constant(0.5), g: .constant(0.5), b: .constant(0.5))
    }
}
