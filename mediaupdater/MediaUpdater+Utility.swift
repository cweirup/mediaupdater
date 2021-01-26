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
        
        // Check last segment for a year date. If exists, remove
        var titleComponents = updatedTitle.components(separatedBy: " ")
        if (titleComponents[titleComponents.count - 1].isNumber) {
            titleComponents.removeLast()
        }
        
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
    
    static func getNormalizedName(for name: String) -> String {
        // Need to pull this into separate function, then apply semaphore
        // See: https://stackoverflow.com/questions/31944011/how-to-prevent-a-command-line-tool-from-exiting-before-asynchronous-operation-co/31944445

        let urlString = "https://api.tvmaze.com/search/shows"
        
        var newFileName = name
        
        var components = URLComponents(string: urlString)!
        components.queryItems = [URLQueryItem(name: "q", value: name)]
        
        // This fixed my semaphore issue
        // https://stackoverflow.com/questions/31944011/how-to-prevent-a-command-line-tool-from-exiting-before-asynchronous-operation-co/31944445
        // Also see this for spliting up the code
        // https://github.com/stupergenius/Bens-Log/blob/master/blog-projects/swift-command-line/btc.swift
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            
            if let _data = data {

                if let showResponse = try? JSONDecoder().decode([ShowResponse].self, from: _data) {
                //print("In with the data response.")
                //let showResponse = try JSONDecoder().decode([ShowResponse].self, from: _data)
                //let fullPath = "\(fileInfo["currentDir"]!)/\(fileInfo["filename"]!)"
                
                    newFileName = showResponse[0].show.name
                    
                }
            }
            
            semaphore.signal()
        }
        
        task.resume()
        
        let _ = semaphore.wait(timeout: .distantFuture)
        
        return newFileName
    }
    
//    static func saveFileWithNewName(dir: String, show: String, season: String, episode: String, fileExtension: String) {
//        let fileManager = FileManager.default
//        
//        _ = try? fileManager.moveItem(atPath: fullPath, toPath: "\(dir)/\(show) s\(season)e\(episode).\(fileExtension)")
//    }
}
