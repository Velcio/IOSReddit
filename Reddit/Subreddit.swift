import Foundation

class Subreddit
{
    var title: String
    var name: String
    //used to load extra topics
    var after: String
    var topics: [Topic] = []
    
    init(title: String, name: String, after: String)
    {
        self.title = title
        self.name = name
        self.after = after
    }
    
    convenience init(title: String, name: String, after: String, topics: [Topic])
    {
        self.init(title: title, name: name, after: after)
        
    }
}

extension Subreddit
{
    convenience init(json: NSDictionary) throws {
        //checks if the surrounding data tag is present
        guard let data = json["data"] as? NSDictionary else {
            throw Error.MissingJsonProperty(name: "data")
        }
        //checks the title
        guard let title = data["title"] as? String else {
            throw Error.MissingJsonProperty(name: "title")
        }
        //checks the reddit name
        guard let name = data["display_name"] as? String else {
            throw Error.MissingJsonProperty(name: "display_name")
        }
        
        self.init(title: title, name: name, after: "", topics: [])
    }
}
/*
*/