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
    var ports: String
    var labels = [String: String]()
    var compose_project: String
    
    init(json: [String: Any]) {
        
        id  = json["ID"] as! String
        
        name =  json["Names"] as! String
        ports =  json["Ports"] as! String
        for label in (json["Labels"] as! String).components(separatedBy: ",") {
            let label_components = label.components(separatedBy: "=")
            if label_components.count == 2 {
                labels[label_components[0]] = label_components[1]
            }
        }
        
        if let project_name = labels["com.docker.compose.project"] {
            compose_project = project_name as String
        } else {
            compose_project = "other"
        }
        
        
        if (json["Status"] as! String).contains("Up") {
            active = true
        } else {
            active = false
        }
    }
}
