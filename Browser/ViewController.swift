import UIKit
import WebKit

protocol HistoryDelegate {
    func didSelectHistory(url: URL)
}

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var newTabButton: UIToolbar!
    @IBOutlet weak var tabViewButton: UIToolbar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!

    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    
    var tab: [Tab] = []
    var history: [Tab] = []
    
    class Tab {
        var url: URL?
        var title: String?
        // Add any additional properties as needed
        
        init(url: URL?, title: String?) {
            self.url = url
            self.title = title
        }
    }
    
    
    // Enable or disable the back and fo    rward buttons based on the web view's navigation state
    func updateNavigationButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [self] in
            if let url = URL(string: "https://google.com") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
        NotificationCenter.default.addObserver(self,
          selector: #selector(self.keyboardNotification(notification:)),
          name: UIResponder.keyboardWillChangeFrameNotification,
          object: nil)
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Settings", image: UIImage(systemName: "gearshape"), handler: { (_) in
                    self.performSegue(withIdentifier: "settingsSegue", sender: self)
                }),
                UIAction(title: "Extensions", image: UIImage(systemName: "puzzlepiece.extension"), handler: { (_) in
                    self.performSegue(withIdentifier: "ExtensionsSegue", sender: self)
                }),
                UIAction(title: "Themes", image: UIImage(systemName: "paintbrush"), handler: { (_) in
                    self.performSegue(withIdentifier: "ThemesSegue", sender: self)
                }),
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (_) in
                    if let urlString = self.webView.url?.absoluteString {
                        let message = "Check out this link:"
                        if let url = URL(string: urlString) {
                            let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    }
                }),
                UIAction(title: "Split View", image: UIImage(systemName: "square.bottomhalf.filled"), handler: { [self] (_) in
                    self.performSegue(withIdentifier: "splitView", sender: self)
                }),
                UIAction(title: "Find on Page", image: UIImage(systemName: "magnifyingglass"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Zoom", image: UIImage(systemName: "arrow.up.left.and.down.right.magnifyingglass"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Request Desktop Browsing", image: UIImage(systemName: "desktopcomputer"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Private Mode", image: UIImage(systemName: "eye.slash"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Bookmarks", image: UIImage(systemName: "book"), handler: { (_) in
                    self.performSegue(withIdentifier: "bookmarksSegue", sender: self)
                }),
                UIAction(title: "History", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { (_) in
                    self.performSegue(withIdentifier: "historySegue", sender: self)
                }),
                UIAction(title: "Delete all data", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    self.history.removeAll()
                    print("Deleting All History")
                })
            ]
        }

        var mainMenu: UIMenu {
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        menuButton.menu = mainMenu
        textInput.delegate = self
        webView.navigationDelegate = self
        updateNavigationButtons()
        
        loadingWheel.hidesWhenStopped = true
            }
    

            // Trigger the search when the Return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        if let searchText = textField.text, !searchText.isEmpty {
            // Check if the input is a valid URL
            if let url = URL(string: searchText), url.scheme != nil {
                let request = URLRequest(url: url)
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("Opening URL", request)
                }
            } else {
                let textSearch = searchText.replacingOccurrences(of: " ", with: "+")
                let urlString = "https://www.google.com/search?q=\(textSearch)"
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                        print("Searching", request)
                    }
                }
            }
        }
        updateNavigationButtons()
        return true
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
     
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.view.frame.origin.y = 0.0
        } else {
            self.view.frame.origin.y = -300
        }
    }
    
    
    // Go back to the previous web page
       @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
           if webView.canGoBack {
               webView.goBack()
               print("Go Back")
           }
       }

       // Go forward to the next web page
       @IBAction func forwardButtonTapped(_ sender: UIBarButtonItem) {
           if webView.canGoForward {
               webView.goForward()
               print("Go Forward")
           }
       }
    
    @IBAction func createNewTabButtonPressed(_ sender: UIButton) {
        if let urlString = webView.url?.absoluteString, let title = webView.title {
            print("Saving Tab, Title: ", title, "URL: ", urlString)
            if let url = URL(string: urlString) {
                createNewTab(url: url, title: title)
            }
        }
    }
        
        @IBAction func reloadWebView() {
            webView.reload()
            print("Reload")
        }
        
    func createNewTab(url: URL?, title: String?) {
            let newTab = Tab(url: url, title: title)
            tab.append(newTab)
        for tab in tab{
            print(tab.title!, tab.url!)
        }
    }
    
    func history(url: URL?) {
        let historyTab = Tab(url: url, title: "")
        history.append(historyTab)
        for tab in history{
            print("History", tab.url!)
        }
    }
        
    @IBAction func openTabView(){
        performSegue(withIdentifier: "tabViewSegue", sender: self)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            loadingWheel.startAnimating()
            reloadButton.isHidden = true
            print("Reload Button isHidden, loading wheel isShown")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished Navigation")
        if let pageTitle = webView.title {
            textInput.text = pageTitle
            loadingWheel.stopAnimating()
            reloadButton.isHidden = false
            if let urlString = webView.url?.absoluteString {
                print("URL: ", urlString)
                if let url = URL(string: urlString) {
                    history(url: url)
                }
            }
        }
        updateNavigationButtons()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
        if let destination = segue.destination as? HistoryDelegate {
            print("good")
            for tab in self.history {
                let url = tab.url
                destination.didSelectHistory(url: url!)
                print("Url preparing to transfer", url!)
            }
        } else {
            print("not good")
        }
    }
}



