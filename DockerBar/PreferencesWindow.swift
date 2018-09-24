//
//  PreferencesWindow.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/10/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa
import ServiceManagement

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var launchOnLogin: NSButton!
    var delegate: PreferencesWindowDelegate?

    @IBAction func toggleLaunchOnLogin(_ sender: NSButtonCell) {
        
        let defaults = UserDefaults.standard
        defaults.setValue(convertFromNSControlStateValue(sender.state), forKey: "startDockerBarOnLogin")
        
        if (!SMLoginItemSetEnabled("com.burningpony.DockerBarHelper" as CFString, sender.state.rawValue == 1)) {
            NSLog("Login Item Was Not Successful");
        }
        
    }
    @IBOutlet weak var dockerPathTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let defaults = UserDefaults.standard
        let dockerPath = defaults.string(forKey: "dockerPath") ?? DockerAPI.DEFAULT_DOCKER_PATH
        dockerPathTextField.stringValue = dockerPath
        
        launchOnLogin.state = convertToNSControlStateValue(defaults.integer(forKey: "startDockerBarOnLogin"))
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(dockerPathTextField.stringValue, forKey: "dockerPath")
        delegate?.preferencesDidUpdate()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSControlStateValue(_ input: NSControl.StateValue) -> Int {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
