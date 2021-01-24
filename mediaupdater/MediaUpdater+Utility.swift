//
//  MediaUpdater+Utility.swift
//  mediaupdater
//
//  Created by Chris Weirup on 1/20/21.
//

import Foundation

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

extension MediaUpdater {
    static func getShowInfo(from filename: String) -> (String?, String?, String?) {
        var showName: String?
        var seasonNum: String?
        var episodeNum: String?
        
        let pattern = "(?:\\[{2}(\\d+)\\]{2})?(.+?)[sS]?(\\d+)[eEx](\\d+)[ex-]{0,2}(\\d+)?"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        if let match = regex?.firstMatch(in: filename, options: [], range: NSRange(location: 0, length: filename.utf8.count)) {
            if let showNameRange = Range(match.range(at: 2), in: filename) {
                showName = String(filename[showNameRange])
                //print(showName)
            }
            
            if let seasonNumRange = Range(match.range(at: 3), in: filename) {
                seasonNum = String(filename[seasonNumRange])
            }
            
            if let episodeNumRange = Range(match.range(at: 4), in: filename) {
                episodeNum = String(filename[episodeNumRange])
            }
        }
        return (showName, seasonNum, episodeNum)
    }

    static func formatShowTitle(_ title: String) -> String {
        //var updatedTitle = (title.replacingOccurrences(of: ".", with: " ")).capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let updatedTitle = title.replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Updated Title = \(updatedTitle)")
        // Check last segment for a year date. If exists, remove
        var titleComponents = updatedTitle.components(separatedBy: " ")
        if (titleComponents[titleComponents.count - 1].isNumber) {
            titleComponents.removeLast()
        }
        
        print("Sending back = \(titleComponents.joined(separator: " "))")
        return (titleComponents.joined(separator: " "))
    }
    
    static func getFilePathComponents(from filename: String) -> [String: String] {
        var filePathComponents = Dictionary<String, String>()
        let fileManager = FileManager.default
        var currentDir = fileManager.currentDirectoryPath
        var fullFilePath = ""
        var fileURL: URL
        
        if (!fileManager.fileExists(atPath: filename)) {
            fullFilePath.append(currentDir)
            fullFilePath.append("/\(filename)")
        } else {
            fullFilePath = filename
            currentDir = (URL(fileURLWithPath: fullFilePath).deletingLastPathComponent()).path
        }
        
        fileURL = URL(fileURLWithPath: fullFilePath)

        filePathComponents["currentDir"] = currentDir
        filePathComponents["filename"] = fileURL.lastPathComponent
        filePathComponents["extension"] = fileURL.pathExtension
        
        return filePathComponents
    }
}
