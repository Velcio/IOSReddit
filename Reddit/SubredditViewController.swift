import UIKit
import CoreData

class SubredditViewController : UITableViewController
{
    var subreddit: Subreddit!
    var currentTask: NSURLSessionTask?
    
    let managedObjectContext = DataController().managedObjectContext
    
    override func viewDidLoad() {
        navigationItem.title = subreddit.title
        //to get the button on the ipad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
        }
        
        tableView.delegate = self
        
        if subreddit.topics.count == 0 {
            loadTopics()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subreddit.topics.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {
            addTopics()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topic = subreddit.topics[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! TopicCell
        
        cell.titleLabel.text = topic.title
        cell.authorLabel.text = topic.author
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        cell.createdLabel.text = formatter.stringFromDate(topic.created)
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
                
        if topic.thumbnail != "self" && topic.thumbnail != ""
        {
            let url = NSURL(string: topic.thumbnail)!
            currentTask = TopicService.sharedService.getImageFromUrl(url) {
                result in switch result {
                case .Success(let data):
                    cell.thumbnailImageView.image = UIImage(data: data)
                case .Failure(let error):
                    debugPrint(error)
                }
            }
            
            currentTask?.resume()
        } else {
            cell.thumbnailImageView.image = UIImage(named: "Reddit")
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let linkViewController = segue.destinationViewController as! LinkViewController
        let topic = subreddit.topics[tableView.indexPathForSelectedRow!.row]
        let cell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! TopicCell
        
        if let image = cell.thumbnailImageView.image {
            linkViewController.thumbnail = image
        }
        linkViewController.topic = topic
    }
        
    @IBAction func refreshTopics() {
        addTopics()
    }
    
    func addTopics() {
        currentTask = TopicService.sharedService.createFetchTask(subreddit, after: subreddit.after) {
            [unowned self] result in switch result {
            case .Success(let topics):
                for topic in topics {
                    self.subreddit.topics.append(topic)
                }
                self.tableView.reloadData()
                
                self.saveTopics()
            case .Failure(let error):
                debugPrint(error)
            }
            
        }
        currentTask!.resume()
    }
    
    func loadTopics() {
        let filter = NSPredicate(format: "name == %@", subreddit.name)
        let fetchrequest = NSFetchRequest(entityName: "Subreddit")
        fetchrequest.predicate = filter
        
        do {
            var subredditData: SubredditData
            if let data = try managedObjectContext.executeFetchRequest(fetchrequest) as? [SubredditData] {
                subredditData = data[0]
            } else {
                debugPrint("subreddit doesn't exist")
                return
            }
            
            if subredditData.topics!.count == 0 {
                refreshTopics()
                return
            }
            
            var topics: [Topic] = []
            
            for topicData in subredditData.topics!.allObjects as! [TopicData] {
                guard let title = topicData.title else {
                    debugPrint("title doesn't exist")
                    return
                }
                guard let content = topicData.content else {
                    debugPrint("content doesn't exist")
                    return
                }
                guard let author = topicData.author else {
                    debugPrint("author doesn't exist")
                    return
                }
                guard let created = topicData.created else {
                    debugPrint("created doesn't exist")
                    return
                }
                guard let url = topicData.url else {
                    debugPrint("url doesn't exist")
                    return
                }
                guard let thumbnail = topicData.thumbnail else {
                    debugPrint("thumbnail doesn't exist")
                    return
                }
                
                let topic = Topic(title: title, content: content, author: author, thumbnail: thumbnail, url: url, created: created)
                topics.append(topic)
            }
            
            subreddit.topics = topics
            
            try managedObjectContext.save()
            
            self.tableView.reloadData()
        } catch {
            fatalError("Failed to load topics \(error)")
        }
    }
    
    func saveTopics() {
        let filter = NSPredicate(format: "name == %@", subreddit.name)
        let fetchrequest = NSFetchRequest(entityName: "Subreddit")
        fetchrequest.predicate = filter
        
        do {
            var subredditData: SubredditData
            if let data = try managedObjectContext.executeFetchRequest(fetchrequest) as? [SubredditData] {
                subredditData = data[0]
            } else {
                debugPrint("subreddit doesn't exist")
                return
            }
            
            var topics: [TopicData] = []
            
            for topic in subreddit.topics {
                let topicData = NSEntityDescription.insertNewObjectForEntityForName("Topic", inManagedObjectContext: managedObjectContext) as! TopicData
                
                topicData.setValue(topic.title, forKey: "title")
                topicData.setValue(topic.content, forKey: "content")
                topicData.setValue(topic.author, forKey: "author")
                topicData.setValue(topic.thumbnail, forKey: "thumbnail")
                topicData.setValue(topic.url, forKey: "url")
                topicData.setValue(topic.created, forKey: "created")
                
                topics.append(topicData)
            }
            
            subredditData.topics = NSSet(array: topics)
            
            try managedObjectContext.save()
        } catch {
            fatalError("Failed to save topics \(error)")
        }
    }
}