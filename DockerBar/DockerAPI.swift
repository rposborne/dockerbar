//
//  DockerAPI.swift
//  DockerBar
//
//  Created by Russell Osborne on 2/6/17.
//  Copyright © 2017 Russell Osborne. All rights reserved.
//

import Foundation

class DockerAPI {
    
    
    func version(success: (_: String) -> Void){
        containerCommand(command: ["version"]) { (output: [String]) in
            let pattern = "\\s+Version:\\s+(.*)"
            let versionLine = output[1]
            print("\(versionLine)")
            let groups = versionLine.capturedGroups(withRegex: pattern)
            if groups.count > 0 {
                success(groups[0])
            } else {
                success("?")
            }
        }
    }
    
    func containers(success: (_: [DockerContainer]) -> Void) {
        
        containerCommand(command: ["ps", "-a", "--format", "'{{ json . }}'"]) { (output: [String]) in
            let containerStrings = output.filter { (x) -> Bool in
                !x.isEmpty
                }.map { (x) -> String in
                    x.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            
            var containers: [DockerContainer] = []
            
            
            for item in containerStrings {
                let truncated = String(item.characters.dropFirst())
                let stringWithoutQuotes = truncated.substring(to: truncated.index(before: truncated.endIndex))
                
                let data = stringWithoutQuotes.data(using: .utf8)!
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]{
                        let container = DockerContainer(json: json)
                        containers.append(container)
                        
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
            }
            
            success(containers)
            
        }
    }
    
    func containerCommand(command: [String], success: (_: [String]) -> Void) {
        
        let task = Process()
        
        task.launchPath = "/usr/local/bin/docker"
        task.arguments = command
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        
        //        var output = ""
        //        outHandle.readabilityHandler = { pipe in
        //            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
        //                // Update your view with the new text here
        //                output += "New ouput: \(line)"
        //                success(output)
        //            } else {
        //                output += "Error decoding data: \(pipe.availableData)"
        ////                success(pipe.availableData)
        //            }
        //        }
        //
        task.launch()
        
        var stdOut = String(data: outHandle.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        stdOut = stdOut.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        success( stdOut.components(separatedBy: .controlCharacters) )
    }
}

