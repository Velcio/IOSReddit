import UIKit

class TopicService {
    static let sharedService = TopicService()
  
    private let session: NSURLSession
    
    init() {
        session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }
    
    func getImageFromUrl(url: NSURL, completionHandler: Result<NSData> -> Void) -> NSURLSessionTask {
        return session.dataTaskWithURL(url) {
            data, response, error in
            let completionHandler: Result<NSData> -> Void = {
                result in
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(result)
                }
            }
            
            guard let data = data where error == nil else {
                completionHandler(.Failure(.MissingData))
                return
            }
            
            completionHandler(.Success(data))
        }
    }
    
    func createFetchTask(subreddit: Subreddit, after: String, completionHandler: Result<[Topic]> -> Void) -> NSURLSessionTask {
        var query = subreddit.name + ".json"
        if after != "" {
            query += "?after=" + after
        }
        
        let topicUrl = Properties.properties.properties["baseTopicUrl"] as! String + query
        let url = NSURL(string: topicUrl)!
        
        
        return session.dataTaskWithURL(url) {
            data, response, error in
            
            let completionHandler: Result<[Topic]> -> Void = {
                result in
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(result)
                }
            }
            
            guard let response = response as? NSHTTPURLResponse else {
                completionHandler(.Failure(.NetworkError(message: error?.description)))
                return
            }
            guard response.statusCode == 200 else {
                completionHandler(.Failure(.UnexpectedStatusCode(code: response.statusCode)))
                return
            }
            guard let data = data else {
                completionHandler(.Failure(.MissingData))
                return
            }

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
                
                guard let jsonData = json["data"]!["children"] as? [NSDictionary] else {
                    completionHandler(.Failure(.MissingJsonProperty(name: "children")))
                    return
                }
                guard let after = json["data"]!["after"] as? String else {
                    completionHandler(.Failure(.MissingJsonProperty(name: "after")))
                    return
                }
                
                let results = try jsonData.map { try Topic(json: $0) }
                subreddit.after = after
                completionHandler(.Success(results))
            } catch _ as NSError {
                completionHandler(.Failure(.InvalidJsonData))
            } catch let error as Error {
                completionHandler(.Failure(error))
            }
        }
    }
}