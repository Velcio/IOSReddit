import Foundation

class SubredditService {
    static let sharedService = SubredditService()
    
    private let url: NSURL
    private let session: NSURLSession
    
    init() {
        let subredditsUrl = Properties.properties.properties["popularSubredditUrl"] as! String
        url = NSURL(string: subredditsUrl)!
        session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }
    
    func createFetchTask(completionHandler: Result<[Subreddit]> -> Void) -> NSURLSessionTask {
        return session.dataTaskWithURL(url) {
            data, response, error in
            
            let completionHandler: Result<[Subreddit]> -> Void = {
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
                
                let results = try jsonData.map { try Subreddit(json: $0) }
                completionHandler(.Success(results))
            } catch _ as NSError {
                completionHandler(.Failure(.InvalidJsonData))
                return
            } catch let error as Error {
                completionHandler(.Failure(error))
            }
        }
    }
}