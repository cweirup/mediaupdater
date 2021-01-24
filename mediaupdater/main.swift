//
//  main.swift
//  mediaupdater
//
//  Created by Chris Weirup on 1/20/21.
//

import Foundation
import ArgumentParser

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

struct MediaUpdater: ParsableCommand {
    
    // MARK: - Configure parsable command
        
    /// The configuration for a command.
    static let configuration = CommandConfiguration(
        commandName: "mediaupdater",
        abstract: MediaUpdater.abstract,
        discussion: MediaUpdater.discussion,
        shouldDisplay: true,
        helpNames: [.long]
    )
    
    enum Action: EnumerableFlag {
        case rename
        case getSubs
    }
    
    @Flag(help: "Command to execute on the file. Defaults to Rename.")
    var actionType: Action = .rename
    
    @Argument(
        parsing: .remaining,
        help: "File to execute the action."
    )
    var videoFile: [String]
    
    // MARK: - Main
    
    func run() throws {
        let fileInfo = MediaUpdater.getFilePathComponents(from: videoFile[0])
        
        switch actionType {
        case .rename:
            // Need to pull this into separate function, then apply semaphore
            // See: https://stackoverflow.com/questions/31944011/how-to-prevent-a-command-line-tool-from-exiting-before-asynchronous-operation-co/31944445
            let showInfo = MediaUpdater.getShowInfo(from: fileInfo["filename"]!)
            let fileManager = FileManager.default
            let lookupFileName = MediaUpdater.formatShowTitle(showInfo.0!)
            let lookupFileNameEncoded = lookupFileName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let newFileName = "\(lookupFileName) s\(showInfo.1!)e\(showInfo.2!)"
            let urlString = "https://api.tvmaze.com/search/shows"
            let urlParams = ["q": MediaUpdater.formatShowTitle(showInfo.0!)]
            
            // This fixed my semaphore issue
            // https://stackoverflow.com/questions/31944011/how-to-prevent-a-command-line-tool-from-exiting-before-asynchronous-operation-co/31944445
            let semaphore = DispatchSemaphore(value: 0)
            
            let url = URL(string: "\(urlString)?q=\(lookupFileNameEncoded)")!
            
            print("URL = \(url.absoluteString)")
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let _data = data {

                    do {
                        //if let showResponse = try? JSONDecoder().decode([ShowResponse].self, from: _data) {
                        print("In with the data response.")
                        let showResponse = try JSONDecoder().decode([ShowResponse].self, from: _data)
                        let fullPath = "\(fileInfo["currentDir"]!)/\(fileInfo["filename"]!)"
                        let cleanFileName = showResponse[0].show.name
                        
                        try? fileManager.moveItem(atPath: fullPath, toPath: "\(fileInfo["currentDir"]!)/\(cleanFileName) s\(showInfo.1!)e\(showInfo.2!).\(fileInfo["extension"]!)")

                    } catch DecodingError.keyNotFound(let key, let context) {
                        Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                    } catch DecodingError.valueNotFound(let type, let context) {
                        Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.dataCorrupted(let context) {
                        Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                    } catch let error as NSError {
                        NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    }
                }
                
                semaphore.signal()
            }
            
            task.resume()
            
            let _ = semaphore.wait(timeout: .distantFuture)
            
//            NetworkManager.get(url: urlString, params: urlParams) { (data, error) in
//
//                //let _ = semaphore.wait(timeout: .distantFuture)
//
//                if let _data = data {
//
//                    let jsonData = NSString(data: _data, encoding: String.Encoding.utf8.rawValue)
//                    print("Data from loadFolders = \(String(describing: jsonData))")
//
//                    if let showResponse = try? JSONDecoder().decode([ShowResponse].self, from: _data) {
//                        do {
//                            let fullPath = "\(fileInfo["currentDir"]!)/\(fileInfo["filename"]!)"
//                            //let cleanFileName = MediaUpdater.formatShowTitle(showInfo.0!)
//                            let cleanFileName = showResponse[0].shows[0].name
//
//                            try fileManager.moveItem(atPath: fullPath, toPath: "\(fileInfo["currentDir"]!)/\(cleanFileName) s\(showInfo.1!)e\(showInfo.2!).\(fileInfo["extension"]!)")
//
//                        } catch let error as Error {
//                            print("Unable to rename file. \(error)")
//                        }
//                    }
//
//                    semaphore.signal()
//                }
//
//            }
            
            
            
//            do {
//                let fullPath = "\(fileInfo["currentDir"]!)/\(fileInfo["filename"]!)"
//                let cleanFileName = mediaupdater.MediaUpdater.formatShowTitle(showInfo.0!)
//
//                try fileManager.moveItem(atPath: fullPath, toPath: "\(fileInfo["currentDir"]!)/\(cleanFileName) s\(showInfo.1!)e\(showInfo.2!).\(fileInfo["extension"]!)")
//
//            } catch let error as Error {
//                print("Unable to rename file. \(error)")
//            }
            
        case .getSubs:
            print("getSubs")
        }
    }
}


MediaUpdater.main()
    

