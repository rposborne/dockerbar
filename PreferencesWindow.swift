//
//  PreferencesWindow.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/10/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PreferencesWindowDelegate?

    @IBOutlet weak var dockerPathTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let defaults = UserDefaults.standard
        let dockerPath = defaults.string(forKey: "dockerPath") ?? DockerAPI.DEFAULT_DOCKER_PATH
        dockerPathTextField.stringValue = dockerPath
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
