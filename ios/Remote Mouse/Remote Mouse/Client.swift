//
//  Client.swift
//  Remote Mouse
//
//  Created by Lucas Popp on 5/31/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation
import SwiftSocket

enum ServerLang {
    case node
    case swift
}

class CustomClient: TCPClient {
    
    var currentServerLanguage: ServerLang?
    
    func setLanguage(_ lang: ServerLang?) {
        currentServerLanguage = lang
    }
    
    private func encapsulatedSend(_ string: String) {
        print(string)
        switch currentServerLanguage {
        case nil:
            print("Missing server language")
            break
        case .node:
            send(string: "\(string)")
            return
        case .swift:
            send(string: "\(string)|||")
            return
        }
    }
    
    func click() {
        encapsulatedSend("clk")
    }
    
    func pan(translation: CGPoint) {
        encapsulatedSend("mv:\(Int(round(translation.x * 2.5))),\(Int(round(translation.y * 2.5)))")
    }
    
    func key(_ keyValue: String) {
        encapsulatedSend("key:\(keyValue)")
    }
    
    func type(_ string: String) {
        encapsulatedSend("type:\(string)")
    }
    
    func sendClose() {
        encapsulatedSend("close")
    }
    
}
