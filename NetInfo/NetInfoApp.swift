//
//  NetInfoApp.swift
//  NetInfo
//
//  Created by Noah Freising on 04.07.23.
//

import SwiftUI

@main
struct NetInfoApp: App {
    @State var interfaces: Set<InterfaceWithIP>
    @State var selectedInterface: String
    @State var preferIpv6: Bool
    @State var showHostName: Bool
    @State var hostName: String // Accessing the hostname this way requires network access
    @State var truncLength: Int
    @State var displayString: String
    
    init() {
        interfaces = getNetworkInterfaces()!
        selectedInterface = "en0"
        preferIpv6 = false
        showHostName = false
        hostName = Host.current().name ?? ""
        truncLength = 32
        displayString = "NetInfo"
        //print(createDisplayString(interfaceName: selectedInterface, preferIpv6: preferIpv6, showHostName: showHostName, hostName: hostName, truncLength: truncLength)!)
    }
    
    
    
    var body: some Scene {
        MenuBarExtra(createDisplayString(ipAddr: interfaces.first { $0.name == selectedInterface}!.getIP(preferIpv6: preferIpv6), showHostName: showHostName, hostName: hostName, truncLength: truncLength) ?? "NetInfo") {
            NetInfoMenu(interfaces: $interfaces, selectedInterface: $selectedInterface,preferIpv6: $preferIpv6, showHostName: $showHostName, hostName: $hostName, truncLength: $truncLength, displayString: $displayString)
        }

        Window("Options", id: "options") {
            OptionsView(truncLength: $truncLength, preferIpv6: $preferIpv6)
        }
    }
}

