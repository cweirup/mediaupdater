//
//  NetworkManager.swift
//  mediaupdater
//
//  Created by Chris Weirup on 1/22/21.
//

import Foundation

class NetworkManager {
    
    private static func config() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        return config
    }

    private static func session() -> URLSession {
        let session = URLSession(configuration: config())
        return session
    }
    
    private static func request(url: String, params: [String: Any]) -> URLRequest {
        
        // Components part from this website:
        // https://stackoverflow.com/questions/27723912/swift-get-request-with-parameters
        var components = URLComponents(string: url)!
        components.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value as? String)
        }
        
        //print(components.url?.absoluteString)
        var request = URLRequest(url: components.url!)
        
        // For now, going to comment this out. Looks like with iOS 13 and macOS 15,
        // using httpBody is not allowed for GET requests. You would need to append
        // any parameters as a query string to the URL. For now I don't need to
        // do any special parameters.
        // MORE INFO: https://stackoverflow.com/questions/56955595/1103-error-domain-nsurlerrordomain-code-1103-resource-exceeds-maximum-size-i
        // POTENTIAL FIX: https://stackoverflow.com/questions/27723912/swift-get-request-with-parameters
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
//        } catch let error {
//            print(error.localizedDescription)
//        }
        request.timeoutInterval = 60
        return request
    }
    
    static func get( url: String, params: [String: Any] = [:], callback: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        var request: URLRequest = self.request(url: url, params: params)
        request.httpMethod = "GET"
        let task = session().dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                callback(data, error)
            }
        })
        task.resume()
    }
}
