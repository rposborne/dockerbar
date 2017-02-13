//
//  ContainerView.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/7/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Cocoa


class ContainerView: NSView {
    
    @IBOutlet weak var containerSymbol = NSTextField()
    
    @IBOutlet weak var containerText =  NSTextField()
    
    func update(container: DockerContainer) -> Void {
        // do UI updates on the main thread
//        print(container.name)
//        self.containerText.stringValue = "hi"
        DispatchQueue.main.async {
            self.containerSymbol?.stringValue = "other"
            self.containerText?.stringValue = "hi"
        }
    }
}
