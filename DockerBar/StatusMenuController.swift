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
            let groupedContainers = containers.categorise { $0.compose_project as String! }
            for (project, containers) in groupedContainers {
                
                let projectName = NSAttributedString(string: project, attributes: [ NSForegroundColorAttributeName: NSColor.textColor ])
                let projectItem : NSMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
                
                projectItem.attributedTitle = projectName
                projectItem.isEnabled = true
                let projectMenu = NSMenu(title: "Edit")
                self.statusMenu.setSubmenu(projectMenu, for: projectItem)
                statusItem.menu?.insertItem(projectItem, at: 3)
                
                
                
                for container in containers.reversed() {
                    print(project, container.id)
                    
                    var attributes : [String : Any] = [
                        NSFontAttributeName : NSFont.systemFont(ofSize: 24.0),
                        NSForegroundColorAttributeName : NSColor.red
                    ]
                    
                    if (container.active) {
                        attributes[ NSForegroundColorAttributeName] =  NSColor.green
                    }
                    
                    let dot = NSAttributedString(string: "•", attributes: attributes)
                    
                    
                    
                    let name = NSAttributedString(string: " " + container.name, attributes: [ NSForegroundColorAttributeName: NSColor.textColor ])
                    let row = NSMutableAttributedString()
                    
                    row.append(dot)
                    row.append(name)
                    
                    let newItem : NSMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
                    newItem.attributedTitle = row
                    newItem.isEnabled = true
                    newItem.toolTip = container.id
                    
                    projectItem.submenu?.insertItem(newItem, at: 0)
                }
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
