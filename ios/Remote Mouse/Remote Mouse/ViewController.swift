//
//  ViewController.swift
//  Remote Mouse
//
//  Created by Lucas Popp on 5/30/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController, SessionListener {
    
    @IBOutlet weak var trackpad: UIView!
    @IBOutlet weak var scrollView: UIView!
    
    var client: CustomClient?
    var lastTranslation: CGPoint = CGPoint.zero
    
    var isForceTouching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Not Connected"
        
        SessionManager.shared.addListener(self)
        SessionManager.shared.attemptToRestoreLastConnection()
    }
    
    func serverChanged(_ server: Server?) {
        title = server?.hostName ?? "Not Connected"
        
        guard let server = server else { return }
        client = CustomClient(address: server.IP, port: Int32(server.port))
        
        guard let client = client else {
            print("Unable to create TCP client")
            return
        }
        
        switch client.connect(timeout: 1000) {
        case .success:
            print("Successful TCP connection")
            break
        case .failure(let error):
            print("TCP connection failed")
            print("Error: \(error.localizedDescription)")
            return
        }
        
        var delimCount: Int = 0
        let delim = [Byte]("|".utf8)[0]
        var fullString = ""
        
        while let d = client.read(1, timeout: 10) {
            if d.count == 1 && d[0] == delim {
                delimCount += 1
                
                if delimCount == 3 {
                    delimCount = 0
                    let lang = fullString[..<fullString.index(fullString.endIndex, offsetBy: -2)]
                    
                    switch lang {
                    case "node":
                        client.setLanguage(.node)
                        return
                    case "swift":
                        client.setLanguage(.swift)
                        return
                    default:
                        client.setLanguage(.node)
                        return
                    }
                }
            }
            
            if let str = String(bytes: d, encoding: .utf8) {
                fullString += str
            }
        }
    }
    
    @IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
        client?.click()
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let actual = gesture.translation(in: trackpad)
        var translation: CGPoint!

        if gesture.state == .began {
            translation = actual
        } else if gesture.state == .ended {
            translation = actual
            translation.x -= lastTranslation.x
            translation.y -= lastTranslation.y
            lastTranslation = CGPoint.zero
        } else {
            translation = actual
            translation.x -= lastTranslation.x
            translation.y -= lastTranslation.y
            lastTranslation = actual
        }
        
        client?.pan(translation: translation)
    }
    
    @IBAction func sendKey(_ sender: CmdButton) {
        client?.key(sender.key)
    }
    
    @IBAction func openKeyboard() {
        let alert = UIAlertController(title: "Send Text", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addTextField { (textField) in
            textField.placeholder = "Keyboard input"
        }
        
        alert.addAction(UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler: { (action) in
            if let string = alert.textFields?.first?.text {
                self.client?.type(string)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }

}

