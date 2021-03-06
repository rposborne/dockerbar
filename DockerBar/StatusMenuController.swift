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

//    var projectViews = [String: NSMenuItem]()

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "Icon")

        let appearance = UserDefaults.standard.string(forKey:"AppleInterfaceStyle") ?? "Light"
        if appearance == "Dark" {
            icon?.isTemplate = true
        }

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
            let groupedContainers = containers.categorise { $0.compose_project as String }
            for (project, containers) in groupedContainers {
                // Remove existing project groupings and all of children
                if let projectView = self.statusMenu.item(withTitle: project) {
                    self.statusMenu.removeItem(projectView)
                }


                buildProjectView(project: project, containers: containers)
            }
        }
    }

    func buildProjectView(project: String, containers: [DockerContainer]) -> Void {
        let projectName = NSAttributedString(string: project, attributes: convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: NSFont.systemFont(ofSize: NSFont.systemFontSize)]))
        let projectItem : NSMenuItem = NSMenuItem(title: project, action: nil, keyEquivalent: "")

        projectItem.attributedTitle = projectName
        projectItem.isEnabled = true
        let projectMenu = NSMenu(title: "Edit")
        self.statusMenu.setSubmenu(projectMenu, for: projectItem)
        statusItem.menu?.insertItem(projectItem, at: 3)

        for container in containers.reversed() {
            projectItem.submenu?.insertItem(buildContainerDefaultView(container: container), at: 0)
            projectItem.submenu?.insertItem(buildContainerCopyIdView(container: container), at: 0)
        }
    }

    func buildContainerDefaultView(container: DockerContainer) -> NSMenuItem {
        var attributes : [String : Any] = [
            NSAttributedString.Key.font.rawValue : NSFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor.rawValue : NSColor.red
        ]

        if (container.active) {
            attributes[NSAttributedString.Key.foregroundColor.rawValue] =  NSColor.green
        }

        let dot = NSAttributedString(string: "•", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))

        let name = NSAttributedString(string: " " + container.name, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.font.rawValue : NSFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor.rawValue: NSColor.textColor
            ])
        )
        let row = NSMutableAttributedString()

        row.append(dot)
        row.append(name)


        let newItem : NSMenuItem = NSMenuItem(title: "", action: #selector(toggleContainer(_:)), keyEquivalent: "")
        newItem.attributedTitle = row
        newItem.toolTip = container.id
        newItem.target = self
        newItem.representedObject = container
        return newItem
    }

    func buildContainerCopyIdView(container: DockerContainer) -> NSMenuItem {
        let name = NSAttributedString(string: "Copy " + container.id, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.font.rawValue : NSFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor.rawValue: NSColor.textColor
            ])
        )

        let key = String(utf16CodeUnits: [unichar(1)], count: 1) as String

        let newItem : NSMenuItem = NSMenuItem(
            title: "",
          action: #selector(saveContainerIDtoPastboard(_:)),
          keyEquivalent: "")

        newItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: UInt(Int(NSEvent.ModifierFlags.option.rawValue)))
        newItem.keyEquivalent = key
        newItem.attributedTitle = name
        newItem.toolTip = container.id
        newItem.target = self
        newItem.representedObject = container
        newItem.isAlternate = true

        return newItem
    }

    @objc func toggleContainer(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            let container = sender.representedObject as! DockerContainer
            let commandToRun = container.active ? "stop" : "start"
            self.docker.containerCommand(command: [ commandToRun, container.id]) {_ in
                self.showContainers()
            }
        }

    }

    @objc func saveContainerIDtoPastboard(_ sender: NSMenuItem) -> Void {
        let container = sender.representedObject as! DockerContainer
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(container.id, forType: NSPasteboard.PasteboardType.string)
    }

    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }

    @IBAction func updateClicked(_ sender: NSMenuItem) {
        showContainers()
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
