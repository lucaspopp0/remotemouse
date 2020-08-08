//
//  SessionManager.swift
//  Remote Mouse
//
//  Created by Lucas Popp on 5/30/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation
import SwiftSocket

struct Server {
    var hostName: String
    var IP: String
    var port: Int
}

protocol SessionListener {
    
    func serverChanged(_ server: Server?)
    
}

class SessionManager {
    
    let BASE_URL = URL(string: "http://remotemouse.us-west-2.elasticbeanstalk.com")!
    
    static var shared = SessionManager()
    
    var currentServer: Server? {
        didSet {
            UserDefaults.standard.set(currentServer?.hostName ?? nil, forKey: "lastHost")
            
            for listener in listeners {
                listener.serverChanged(currentServer)
            }
        }
    }
    
    var currentClient: CustomClient?
    
    private var listeners: [SessionListener] = []
    
    func addListener(_ listener: SessionListener) {
        listeners.append(listener)
    }
    
    func attemptToRestoreLastConnection() {
        guard let lastHost = UserDefaults.standard.string(forKey: "lastHost") else { return }
        
        let activeServers = getActiveServers()
        for server in activeServers {
            if server.hostName == lastHost {
                currentServer = server
                return
            }
        }
    }
    
    func getActiveServers() -> [Server] {
        var servers: [Server] = []
        
        let endpt = URL(string: "/hosts", relativeTo: BASE_URL)!
        var isDone: Bool = false
        
        let task = URLSession.shared.dataTask(with: endpt) { (data, response, error) in
            guard let data = data else { return isDone = true }
            guard let arr = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return isDone = true }
            
            for blob in arr {
                if let name = blob["name"] as? String, let address = blob["address"] as? String, let port = blob["port"] as? Int {
                    servers.append(Server(hostName: name, IP: address, port: port))
                }
            }
            
            isDone = true
        }
        
        task.resume()
        
        while !isDone {}
        
        return servers
    }
    
}
