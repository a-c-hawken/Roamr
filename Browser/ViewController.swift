import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var newTabButton: UIToolbar!
    @IBOutlet weak var tabViewButton: UIToolbar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!

    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let url = URL(string: "https://google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Settings", image: UIImage(systemName: "gearshape"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Extensions", image: UIImage(systemName: "puzzlepiece.extension"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Themes", image: UIImage(systemName: "paintbrush"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Split View", image: UIImage(systemName: "square.bottomhalf.filled"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Reload", image: UIImage(systemName: "arrow.clockwise"), handler: { (_) in
                    // Handle the action for the standard item
                }),
                UIAction(title: "Request desktop browsing", image: UIImage(systemName: "desktopcomputer"), handler: { (_) in
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
        updateNavigationButtons()
            }

            // Trigger the search when the Return key is pressed
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder() // Dismiss the keyboard
                if let searchText = textField.text, !searchText.isEmpty {
                    let textSearch = searchText.replacingOccurrences(of: " ", with: "+")
                    let urlString = "https://www.google.com/search?q=\(textSearch)"
                    if let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        webView.load(request)
                    }
                }
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

       // Enable or disable the back and forward buttons based on the web view's navigation state
       func updateNavigationButtons() {
           backButton.isEnabled = webView.canGoBack
           forwardButton.isEnabled = webView.canGoForward
       }
}
