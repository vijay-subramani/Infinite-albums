//
//  HttpRequestHelper.swift
//  MVVMExample
//
//  Created by John Codeos on 06/19/20.
//

import Foundation

enum HTTPHeaderFields {
    case application_json
    case application_x_www_form_urlencoded
    case none
}

class HttpRequestHelper {
    var dataTasks : [URLSessionDataTask] = []

    func GET(url: String, params: [String: String], httpHeader: HTTPHeaderFields, success: @escaping (Data)->Void, failure: @escaping (Error?)->Void) {
        
        if Reachability.isConnectedToNetwork()
        {
            guard var components = URLComponents(string: url) else {
                print("Error: cannot create URLCompontents")
                return
            }
            components.queryItems = params.map { key, value in
                URLQueryItem(name: key, value: value)
            }

            guard let url = components.url else {
                print("Error: cannot create URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            switch httpHeader {
            case .application_json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .application_x_www_form_urlencoded:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            case .none: break
            }

            
            // .ephemeral prevent JSON from caching (They'll store in Ram and nothing on Disk)
            let config = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: config)
            let dataTask = session.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: problem calling GET")
                    print(error!)
                    failure(error)
                    return
                }
                guard let data = data else {
                    print("Error: did not receive data")
                    failure(error)
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    failure(error)
                    return
                }
                success(data)
            }
            dataTask.resume()
            dataTasks.append(dataTask)
        }else
        {
            let errorMsg = "No Internet Connection"
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : errorMsg])
            failure(error)
        }
        
    }
    
    func cancelGetRequest(url: String) {
      
      // get the index of the dataTask which load this specific news
      // if there is no existing data task for the specific news, no need to cancel it
        guard let dataTaskIndex = dataTasks.firstIndex(where: { task in
        task.originalRequest?.url == URL(string: url)
      }) else {
        return
      }
      
      let dataTask =  dataTasks[dataTaskIndex]
      
      // cancel and remove the dataTask from the dataTasks array
      // so that a new datatask will be created and used to load news next time
      // since we already cancelled it before it has finished loading
      dataTask.cancel()
      dataTasks.remove(at: dataTaskIndex)
    }
}
