//
//  NetworkManager.swift
//  Hackthon
//
//  Created by Manikandan Bangaru on 08/06/23.
//

import Foundation
import Combine
extension URLComponents {
    init(scheme: String = "https",
         host: String = "www.serpapi.com",
         path: String = "/search.json",
         queryItems: [URLQueryItem]) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
        self.queryItems?.append(URLQueryItem(name: "location", value: "Austin,+Texas,+United+States"))
        self.queryItems?.append(URLQueryItem(name: "page", value: "1"))
        self.queryItems?.append(URLQueryItem(name: "ps", value: "10"))
        self.queryItems?.append(URLQueryItem(name: "hl", value: "en"))
        self.queryItems?.append(URLQueryItem(name: "gl", value: "us"))
        self.queryItems?.append(URLQueryItem(name: "engine", value: "walmart"))
        self.queryItems?.append(URLQueryItem(name: "api_key", value: "11840f0e68618898f01f7d3a6e09bafdfcc95bd087947d166fc636368f3a2995"))
    }
}
class NetworkManager {
    //MARK: - Get Product from Network
    public func getProducts(query: String,
        completion: @escaping (WalmartResponse?, Error?) -> ()
    )  {
//        let url = URL(string: "https://serpapi.com/search.json?engine=walmart&query=\(query)&location=Austin,+Texas,+United+States&hl=en&gl=us&api_key=11840f0e68618898f01f7d3a6e09bafdfcc95bd087947d166fc636368f3a2995")!
        if let url = URLComponents(queryItems: [URLQueryItem(name: "query", value: query)]).url {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, _,error in
                if let data = data {
                    /// do exception handler so that our app does not crash
                    do {
                        let result = try JSONDecoder().decode(WalmartResponse.self, from: data)
                        completion(result, nil)
                    } catch {
                        print(error.localizedDescription)
                        completion(nil,error)
                    }
                }
            }
            task.resume()
        }
    }
    
}
