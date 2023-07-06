//
//  NetInfoMenu.swift
//  NetInfo
//
//  Created by Noah Freising on 05.07.23.
//

import SwiftUI

/*
 createDisplayString(interfaceName: selectedInterface, preferIpv6: preferIpv6, showHostName: showHostName, hostName: hostName, truncLength: truncLength) ?? "NetInfo"
 */

// extend String to allow truncating
// from https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e
extension String {
  /*
   Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
   - Parameter length: Desired maximum lengths of a string
   - Parameter trailing: A 'String' that will be appended after the truncation.
    
   - Returns: 'String' object.
  */
  func trunc(length: Int, trailing: String = "…") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}

struct InterfaceWithIP: Hashable{
    var name: String
    var ipv4Addr: String?
    var ipv6Addr: String?
    
    func getIP(preferIpv6: Bool = false) -> String {
        if(ipv6Addr != nil && preferIpv6) {
            return ipv6Addr!
        } else if(ipv4Addr != nil) {
            return ipv4Addr!
        } else if(ipv6Addr != nil) {
            return ipv6Addr!
        } else {
            return "No IP"
        }
    }
}

struct NetInfoMenu: View {
    @Environment(\.openWindow) var openWindow
    @Binding var interfaces: Set<InterfaceWithIP>
    @Binding var selectedInterface: String
    @Binding var preferIpv6: Bool
    @Binding var showHostName: Bool
    @Binding var hostName: String
    @Binding var truncLength: Int
    @Binding var displayString: String
    
    private func refresh() {
        interfaces = getNetworkInterfaces()!
    }
   
    
    var body: some View {
        VStack {
            Group {
                Text("IPv4: \(interfaces.first { $0.name == selectedInterface}!.ipv4Addr ?? "")")
                Text("IPv6: \(interfaces.first { $0.name == selectedInterface}!.ipv6Addr ?? "")")
                Text("Host: \(hostName)")
                
                Button(action: refresh) {
                    Text("Refresh IP Adress")
                }.keyboardShortcut("r")
                
                Button(action: {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.setString(createDisplayString(ipAddr: interfaces.first { $0.name == selectedInterface}!.getIP(preferIpv6: preferIpv6), showHostName: showHostName, hostName: hostName, truncLength: truncLength) ?? "", forType: .string)
                }) {
                    Text("Copy IP to clipboard")
                }.keyboardShortcut("c")
                
                Picker("Choose Interface", selection: $selectedInterface) {
                    ForEach(Array(createDisplayList(interfaces: interfaces, preferIpv6: preferIpv6).keys), id:\.self) { interface in
                        Text(interface)
                    }
                }
            }
            
            Divider()
            Group {
                Toggle(isOn: $preferIpv6) {
                    Text("Prefer IPv6")
                }.keyboardShortcut("6")
                
                Toggle(isOn: $showHostName) {
                    Text("Show Hostname in Menubar")
                }.keyboardShortcut("h")
            }
            Divider()
            
            Button("Options") {
                openWindow(id: "options")
            }.keyboardShortcut("o")
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")

        }
    }
}



func checkInterface(interface: InterfaceWithIP, interfaceName: String) -> Bool {
    return interface.name == interfaceName
}



func createDisplayList(interfaces: Set<InterfaceWithIP>, preferIpv6: Bool) -> Dictionary<String, String> {
    // Use dictionary to map interfaces to IPs and remove duplicates
    var displayList: Dictionary<String, String> = Dictionary()
    for interface in interfaces {
        if (interface.ipv6Addr != nil || interface.ipv4Addr != nil) {
            if (preferIpv6) {
                // first try ipv6 addr
                let text = interface.name + " - " + ((interface.ipv6Addr ?? interface.ipv4Addr) ?? "")
                displayList.updateValue(text, forKey: interface.name)
            } else {
                // first try ipv4 addr
                let text = interface.name + " - " + ((interface.ipv4Addr ?? interface.ipv6Addr) ?? "")
                displayList.updateValue(text, forKey: interface.name)
            }
        }
    }
    return displayList
}

func getNetworkInterfaces() -> Set<InterfaceWithIP>? {
    var interfaces: Set<InterfaceWithIP> = Set()
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }

    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        let name = String(cString: interface.ifa_name)
        
        let interfaceIp = InterfaceWithIP(name: name, ipv4Addr: getNetworkAddress(interfaceName: name)
                                          , ipv6Addr: getNetworkAddress(interfaceName: name, ipv6: true) )
        
        interfaces.insert(interfaceIp)
    }
    freeifaddrs(ifaddr)
    return interfaces
}

// from https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address
// Return IP address of Network interface as a String, or `nil`
func getNetworkAddress(interfaceName: String, ipv6: Bool = false) -> String? {
    var address : String?

    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }

    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee

        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if (!ipv6 && addrFamily == UInt8(AF_INET)) || (ipv6 && addrFamily == UInt8(AF_INET6)) {

            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if  name == interfaceName {

                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    freeifaddrs(ifaddr)

    return address
}

func createDisplayString(ipAddr: String, showHostName: Bool, hostName: String, truncLength: Int) -> String? {
    if (showHostName) {
        let text = "\(ipAddr) - \(hostName)".trunc(length: truncLength)
        return text
    } else {
        let text = "\(ipAddr)".trunc(length: truncLength)
        return text
    }
}

