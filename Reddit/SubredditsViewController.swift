import UIKit
import CoreData

class SubredditsViewController : UITableViewController, UISplitViewControllerDelegate
{
    var subreddits: [Subreddit] = []
    var currentTask: NSURLSessionTask?
    
    let managedObjectContext = DataController().managedObjectContext
    
    override func viewDidLoad() {
        splitViewController!.delegate = self
        loadSubreddits()
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subreddits.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subreddit = subreddits[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("subredditCell", forIndexPath: indexPath)
        cell.textLabel!.text = subreddit.title
        return cell
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let subredditController = (segue.destinationViewController as! UINavigationController).topViewController as! SubredditViewController
        let subreddit = subreddits[tableView.indexPathForSelectedRow!.row]
        subredditController.subreddit = subreddit
    }
    
    @IBAction func refreshClicked()
    {
        subreddits = []
        self.tableView.reloadData()
        currentTask = SubredditService.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let subreddits):
                self.subreddits = subreddits
                self.tableView.reloadData()
                
                self.saveSubreddits()
                
                //creating viewcontroller source: http://stackoverflow.com/questions/24035984/instantiate-and-present-a-viewcontroller-in-swift
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("emptyViewController") as! EmptyViewController
                    let navController = UINavigationController(rootViewController: vc)
                    self.splitViewController!.showDetailViewController(navController, sender: self)
                }
            case .Failure(let error):
                debugPrint(error)
            }
            
        }
        currentTask!.resume()
    }
    
    func loadSubreddits() {
        let subredditFetch = NSFetchRequest(entityName: "Subreddit")
        
        do {
            var subredditsData = try managedObjectContext.executeFetchRequest(subredditFetch) as! [SubredditData]
            
            subredditsData = subredditsData.sort({ (subreddit1, subreddit2) -> Bool in
                return subreddit1.order!.integerValue < subreddit2.order!.integerValue
            })
            
            for subredditData in subredditsData {
                guard let title = subredditData.title else {
                    debugPrint("title was empty")
                    return
                }
                guard let name = subredditData.name else {
                    debugPrint("name was empty")
                    return
                }
                guard let after = subredditData.after else {
                    debugPrint("after was empty")
                    return
                }
                guard let topics = subredditData.topics else {
                    debugPrint("topics was empty")
                    return
                }
                
                let subreddit = Subreddit(title: title, name: name, after: after, topics: topics.allObjects as! [Topic])
                subreddits.append(subreddit)
            }
        } catch {
            fatalError("Failed to fetch subreddits \(error)")
        }
        
        self.tableView.reloadData()
        
        if subreddits.count == 0 {
            refreshClicked()
        }
    }
    
    func saveSubreddits() {
        var order = 0
        let fetchSubredditRequest = NSFetchRequest(entityName: "Subreddit")
        let deleteSubredditRequest = NSBatchDeleteRequest(fetchRequest: fetchSubredditRequest)
        let fetchTopicRequest = NSFetchRequest(entityName: "Topic")
        let deleteTopicRequest = NSBatchDeleteRequest(fetchRequest: fetchTopicRequest)
        do {
            try managedObjectContext.executeRequest(deleteTopicRequest)
            try managedObjectContext.executeRequest(deleteSubredditRequest)
        
        
            for subreddit in subreddits {
                let subredditData =  NSEntityDescription.insertNewObjectForEntityForName("Subreddit", inManagedObjectContext: managedObjectContext)
            
                subredditData.setValue(subreddit.title, forKey: "title")
                subredditData.setValue(subreddit.name, forKey: "name")
                subredditData.setValue(subreddit.name, forKey: "after")
                subredditData.setValue(NSSet(array: subreddit.topics), forKey: "topics")
                subredditData.setValue(order, forKey: "order")
                order++
            }
            
            try managedObjectContext.save()
        } catch {
            fatalError("Failed to save subbreddits \(error)")
        }
        
    }
    
}