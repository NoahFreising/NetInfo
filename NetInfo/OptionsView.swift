//
//  OptionsView.swift
//  NetInfo
//
//  Created by Noah Freising on 05.07.23.
//

import SwiftUI

struct OptionsView: View {
    @Binding var truncLength: Int
    @Binding var preferIpv6: Bool
    
    var body: some View {
        Toggle(isOn: $preferIpv6) {
            Text("Prefer IPv6")
        }
        Picker(selection: $truncLength, label: Text("Truncation Length")) {
            ForEach((2..<35), id: \.self) { val in
                Text("\(val)").tag(val)
            }
        }
    }
}
