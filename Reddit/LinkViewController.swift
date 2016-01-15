import UIKit

class LinkViewController : UIViewController, UIWebViewDelegate
{
    var topic: Topic!
    var thumbnail: UIImage!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var contentWebView: UIWebView!
    
    override func viewDidLoad() {
        navigationItem.title = topic.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        
        titleLabel.text = topic.title
        authorLabel.text = topic.author
        
        contentWebView.delegate = self
        contentWebView.scrollView.bounces = false
        if topic.content != "" {
            contentWebView.loadHTMLString(topic.content.convertHtmlSigns, baseURL: nil)
        } else {
            contentWebView.loadHTMLString("<url target='_blank'>" + topic.url + "<url>", baseURL: nil)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateLabel.text = formatter.stringFromDate(topic.created)
        thumbnailImageView.contentMode = .ScaleAspectFit
        thumbnailImageView.image = thumbnail
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    //open url form webview in safari, source: http://stackoverflow.com/questions/28574272/how-can-i-make-any-links-within-a-webview-open-in-safari-in-xcode
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }
}

extension String {
    var convertHtmlSigns:String {
        return self.componentsSeparatedByString("&lt;").joinWithSeparator("<").componentsSeparatedByString("&gt;").joinWithSeparator(">").componentsSeparatedByString("&amp;").joinWithSeparator("&")
    }
}