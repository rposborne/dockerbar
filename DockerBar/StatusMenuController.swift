//
//  StatusMenuController.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/6/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa
import AppKit

class StatusMenuController: NSObject, PreferencesWindowDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    var preferencesWindow: PreferencesWindow!
    let docker = DockerAPI()

    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "Icon")
        statusItem.image = icon
        statusItem.menu = statusMenu
        dockerVersion()
        showContainers()
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        


    }
    
    func preferencesDidUpdate() {
        showContainers()
    }
    
    
    func dockerVersion() -> Void {
        docker.version() { (version: String) in
            if let dockerVersion = self.statusMenu.item(withTitle: "DockerVersion") {
                dockerVersion.title = "Using Docker " + version
                dockerVersion.isEnabled = false
                dockerVersion.target = nil;
            }
        }
    }
    
    func showContainers() -> Void {
        docker.containers() { (containers: [DockerContainer]) in
            let groupedContainers = containers.categorise { $0.compose_project as String! }
            for (project, containers) in groupedContainers {
                
                let projectName = NSAttributedString(string: project, attributes: [NSFontAttributeName: NSFont.systemFont(ofSize: NSFont.systemFontSize())])
                let projectItem : NSMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
                
                projectItem.attributedTitle = projectName
                projectItem.isEnabled = true
                let projectMenu = NSMenu(title: "Edit")
                self.statusMenu.setSubmenu(projectMenu, for: projectItem)
                statusItem.menu?.insertItem(projectItem, at: 3)
                
                
                
                for container in containers.reversed() {
//                    print(project, container.id)
                    
                    var attributes : [String : Any] = [
                        NSFontAttributeName : NSFont.systemFont(ofSize: 22),
                        NSForegroundColorAttributeName : NSColor.red
                    ]
                    
                    if (container.active) {
                        attributes[ NSForegroundColorAttributeName] =  NSColor.green
                    }
                    
                    let dot = NSAttributedString(string: "•", attributes: attributes)
                    
                    
                    
                    let name = NSAttributedString(string: " " + container.name, attributes: [
                        NSFontAttributeName : NSFont.systemFont(ofSize: 18),
                        NSForegroundColorAttributeName: NSColor.textColor
                        ]
                    )
                    let row = NSMutableAttributedString()
                    
                    row.append(dot)
                    row.append(name)
                    
                    let newItem : NSMenuItem = NSMenuItem(title: "", action: #selector(startContainer(_:)), keyEquivalent: "")
                    newItem.attributedTitle = row
                    newItem.toolTip = container.id
                    newItem.target = self
                    newItem.representedObject = container
                    
                    projectItem.submenu?.insertItem(newItem, at: 0)
                }
            }
        }
    }
    
    func startContainer(_ sender: NSMenuItem) {
        let container = sender.representedObject as! DockerContainer
        docker.containerCommand(command: ["start", container.id]) {_ in 
            
        }
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        showContainers()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
