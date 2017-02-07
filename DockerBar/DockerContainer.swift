//
//  DockerContainer.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/7/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Foundation

class DockerContainer {
    var name: String
    var id: String
    var active: Bool
    
    init(dockerString: String) {
        let components = dockerString.components(separatedBy: "  ").filter { (x) -> Bool in
            !x.isEmpty
            }.map { (x) -> String in
                x.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        print(components)
        id  = components[0]
        name =  components.last!
        
        if components.count > 4 && components[4].contains("Exited") {
            active = false
        } else {
            active = true
        }
    }
}
