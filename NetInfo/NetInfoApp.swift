//
//  NetInfoApp.swift
//  NetInfo
//
//  Created by Noah Freising on 04.07.23.
//

import SwiftUI

@main
struct NetInfoApp: App {
    @State var selectedInterface: String = "en0"
    @State var preferIpv6: Bool = false
    @State var showHostName: Bool = false
    @State var hostName: String = Host.current().name ?? "" // Accessing the hostname this way requires network access
    @State var truncLength: Int = 32
    var body: some Scene {
        MenuBarExtra(createDisplayString(interfaceName: selectedInterface, preferIpv6: preferIpv6, showHostName: showHostName, hostName: hostName, truncLength: truncLength) ?? "NetInfo") {
            
            NetInfoMenu(selectedInterface: $selectedInterface,preferIpv6: $preferIpv6, showHostName: $showHostName, hostName: $hostName, truncLength: $truncLength)
            
        }

        Window("Options", id: "options") {
            OptionsView(truncLength: $truncLength, preferIpv6: $preferIpv6)
        }
    }
}

