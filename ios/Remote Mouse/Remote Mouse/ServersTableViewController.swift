//
//  ServersTableViewController.swift
//  Remote Mouse
//
//  Created by Lucas Popp on 5/30/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import UIKit

class ServersTableViewController: UITableViewController {
    
    var servers: [Server] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        servers = SessionManager.shared.getActiveServers()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Server", for: indexPath)
        cell.textLabel?.text = servers[indexPath.row].hostName
        cell.detailTextLabel?.text = servers[indexPath.row].IP
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SessionManager.shared.currentServer = servers[indexPath.row]
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
