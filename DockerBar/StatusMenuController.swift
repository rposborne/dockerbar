//
//  StatusMenuController.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/6/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa
import AppKit

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    

    let docker = DockerAPI()

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "Icon")
        statusItem.image = icon
        statusItem.menu = statusMenu
        dockerVersion()
        showContainers()
        
    }
    
    func dockerVersion() -> Void {
        docker.version() { (version: String) in
            if let dockerVersion = self.statusMenu.item(withTitle: "DockerVersion") {
                dockerVersion.title = "Using Docker " + version
            }
        }
    }
    
    func showContainers() -> Void {
        docker.containers() { (containers: [DockerContainer]) in
            for container in containers {
                print(container.id)
                var statusColor = [ NSForegroundColorAttributeName: NSColor.red ]
                
                if (container.active) {
                    statusColor = [ NSForegroundColorAttributeName: NSColor.green ]
                }
                
                let dot = NSAttributedString(string: "•", attributes: statusColor)
                
                let name = NSAttributedString(string: " " + container.name, attributes: [ NSForegroundColorAttributeName: NSColor.textColor ])
                let row = NSMutableAttributedString()
                
                row.append(dot)
                row.append(name)
                
                let newItem : NSMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
                newItem.attributedTitle = row
                newItem.isEnabled = true
                newItem.target = self
                newItem.toolTip = container.id
                
                statusItem.menu?.insertItem(newItem, at: 3)
            }
        }
    }
    
    func startContainer(_ sender: NSMenuItem) {
        print("start")
    }

    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        dockerVersion()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
