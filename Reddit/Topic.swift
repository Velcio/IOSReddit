import Foundation

class Topic
{
    var title: String
    var content: String
    var author: String
    var thumbnail: String
    var url: String
    var created: NSDate
    
    init(title: String, content: String, author: String, thumbnail: String, url: String, created: NSDate) {
        self.title = title
        self.content = content
        self.author = author
        self.thumbnail = thumbnail
        self.url = url
        self.created = created
    }
}

extension Topic
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
        //checks the content
        var content: String
        if let c = data["selftext_html"] as? String {
            content = c
        } else {
            content = ""
        }
        //checks the author
        guard let author = data["author"] as? String else {
            throw Error.MissingJsonProperty(name: "author")
        }
        //cehcks the thumbnail
        guard let thumbnail = data["thumbnail"] as? String else {
            throw Error.MissingJsonProperty(name: "thumbnail")
        }
        //checks the url
        guard let url  = data["url"] as? String else {
            throw Error.MissingJsonProperty(name: "url")
        }
        //checks the created_date
        guard let created = data["created_utc"] as? Int else {
            throw Error.MissingJsonProperty(name: "created_utc")
        }
        let interval = NSTimeInterval(created)
        let date = NSDate(timeIntervalSince1970: interval)
        
        self.init(title: title, content: content, author: author, thumbnail: thumbnail, url: url, created: date)
    }
}