import UIKit
import WebKit

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
    
    var tabs: [String] = []
    
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
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Settings", image: UIImage(systemName: "gearshape"), handler: { (_) in
                    self.performSegue(withIdentifier: "settingsSegue", sender: self)
                }),
                UIAction(title: "Extensions", image: UIImage(systemName: "puzzlepiece.extension"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Themes", image: UIImage(systemName: "paintbrush"), handler: { (_) in
                    // Handle the action for the standard item
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
                    // Handle the action for the disabled item
                }),
                UIAction(title: "History", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { (_) in
                    // Handle the action for the disabled item
                }),
                UIAction(title: "Delete all data", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    // Handle the action for the delete item
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
                    let textSearch = searchText.replacingOccurrences(of: " ", with: "+")
                    let urlString = "https://www.google.com/search?q=\(textSearch)"
                    if let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        DispatchQueue.main.async {
                            self.webView.load(request)
                        }
                    }
                }
                updateNavigationButtons()
                return true
    }
    
    // Go back to the previous web page
       @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
           if webView.canGoBack {
               webView.goBack()
           }
       }

       // Go forward to the next web page
       @IBAction func forwardButtonTapped(_ sender: UIBarButtonItem) {
           if webView.canGoForward {
               webView.goForward()
           }
       }
        
        @IBAction func reloadWebView() {
            webView.reload()
        }
        
    @IBAction func openTabView(){
        performSegue(withIdentifier: "tabViewSegue", sender: self)
    }
    
    @IBAction func newTab(){
        if let urlString = self.webView.url?.absoluteString {
            tabs.append(urlString)
        }
        textInput.text = " "
        if let url = URL(string: "https://google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            loadingWheel.startAnimating()
            reloadButton.isHidden = true
        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let pageTitle = webView.title {
            textInput.text = pageTitle
            loadingWheel.stopAnimating()
            reloadButton.isHidden = false
        }
        
        updateNavigationButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
