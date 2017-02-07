//
//  ContainerView.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/7/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa


class ContainerView: NSView {
    
    @IBOutlet weak var containerSymbol: NSTextField!
    
    @IBOutlet weak var containerText: NSTextField!
    
    func update(container: DockerContainer) -> Void {
        // do UI updates on the main thread
        DispatchQueue.main.async {
            self.containerText.stringValue = container.name
        }
    }
}
