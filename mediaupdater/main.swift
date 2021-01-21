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
            let showInfo = MediaUpdater.getShowInfo(from: fileInfo["filename"]!)
            let fileManager = FileManager.default
            let newFileName = "\(MediaUpdater.formatShowTitle(showInfo.0!)) s\(showInfo.1!)e\(showInfo.2!)"
            
            do {
                let fullPath = "\(fileInfo["currentDir"]!)/\(fileInfo["filename"]!)"
                let cleanFileName = MediaUpdater.formatShowTitle(showInfo.0!)
                try fileManager.moveItem(
                    atPath: fullPath,
                    toPath: "\(fileInfo["currentDir"]!)/\(cleanFileName) s\(showInfo.1!)e\(showInfo.2!).\(fileInfo["extension"]!)"
                )
            } catch let error as Error {
                print("Unable to rename file. \(error)")
            }
            
        case .getSubs:
            print("Wha?")
        }
//        if points < 0 {
//            throw(RuntimeError("Exclamation points must be positive."))
//        }
//
//        if points > 10 {
//            throw(RuntimeError("Too many exclamation points. Max 10."))
//        }
//
//        let pointString = String(repeating: "!", count: points)
//        var quoteText = ""
//        if let quoteType = quoteType {
//            switch quoteType {
//            case .singleQuote: quoteText = "'"
//            case .doubleQuote: quoteText = "\""
//            }
//        }
//        var nameString = name.joined(separator: " ")
//        nameString = nameString.isEmpty ? "World" : nameString
//
//        var greetString = greeting.joined(separator: " ")
//        greetString = greetString.isEmpty ? "Hello" : greetString
//
//        print("\(quoteText)\(greetString), \(nameString)\(pointString)\(quoteText)")
    }
}


MediaUpdater.main()
    

