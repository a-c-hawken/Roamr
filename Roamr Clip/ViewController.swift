import UIKit
import DrawerView
import WebKit

protocol HistoryDelegate {
    func didSelectHistory(url: URL)
}

protocol TabDelegate {
    func didSelectTabView(url: URL, title: String)
}

protocol BookmarkDelegate {
    func didSelectBookmark(url: URL, title: String)
}


class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, ParentViewControllerTabsDelegate, DrawerViewDelegate {
    func didSelectTabView(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        print ("recieved and loaded url: ", request.url!.absoluteString)
    }
    
    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var newTabButton: UIToolbar!
    @IBOutlet weak var tabViewButton: UIToolbar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    var lightmode: Bool = true
    var newWebView: WKWebView!
    var window: UIWindow?
    var adBlockArray: [String] = []
    
    var tab: [Tab] = []
    var history: [Tab] = []
    var bookmarks: [Bookmark] = []
    
    var privateMode: Bool = false
    
    
    class Tab: Codable {
        var url: URL?
        var title: String?
        // Add any additional properties as needed
        
        init(url: URL?, title: String?) {
            self.url = url
            self.title = title
        }
    }
    
    class Bookmark: Codable {
        var title: String?
        var url: URL?
        
        init(title: String?, url: URL?) {
            self.title = title
            self.url = url
        }
    }
    
    
    // Enable or disable the back and fo    rward buttons based on the web view's navigation state
    func updateNavigationButtons() {
        if privateMode == true {}
        else {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0.0
        stopButton.isHidden = true
        //        let drawerView = DrawerView()
        //            drawerView.attachTo(view: self.view)
        //
        //            // Set up the drawer here
        //        drawerView.snapPositions = [.closed, .collapsed, .partiallyOpen, .open]
        //        drawerView.delegate = self
        //
        //        let xOffset: CGFloat = 10
        //        var yOffset: CGFloat = 10
        //        let buttonWidth: CGFloat = 40
        //        let buttonHeight: CGFloat = 40
        //        let spacing: CGFloat = 10
        //
        //        let backButton = UIButton(frame: CGRect(x: xOffset, y: yOffset, width: buttonWidth, height: buttonHeight))
        //        let imageBack = UIImage(systemName: "chevron.backward")
        //        backButton.setImage(imageBack, for: .normal)
        //        backButton.setTitleColor(.blue, for: .normal)
        //        drawerView.addSubview(backButton)
        //
        //        let newTabButton = UIButton(frame: CGRect(x: backButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        //        let imageNewTab = UIImage(systemName: "plus")
        //        newTabButton.setImage(imageNewTab, for: .normal)
        //        newTabButton.setTitleColor(.blue, for: .normal)
        //        drawerView.addSubview(newTabButton)
        //
        //        let shareButton = UIButton(frame: CGRect(x: newTabButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        //        let image = UIImage(systemName: "square.and.arrow.up")
        //        shareButton.setImage(image, for: .normal)
        //        shareButton.setTitleColor(.blue, for: .normal)
        //        drawerView.addSubview(shareButton)
        //
        //        let textField = UITextField(frame: CGRect(x: shareButton.frame.maxX + spacing, y: yOffset, width: 200, height: buttonHeight))
        //        textField.placeholder = "Search"
        //        textField.font = UIFont.systemFont(ofSize: 15)
        //        textField.borderStyle = UITextField.BorderStyle.roundedRect
        //        drawerView.addSubview(textField)
        //
        //        let reloadButton = UIButton(frame: CGRect(x: textField.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        //        let imageReload = UIImage(systemName: "arrow.clockwise")
        //        reloadButton.setImage(imageReload, for: .normal)
        //        reloadButton.setTitleColor(.blue, for: .normal)
        //        drawerView.addSubview(reloadButton)
        //
        //        for data in tab {
        //            let tabViewButton = UIButton(frame: CGRect(x: reloadButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        //            let imageTabView = UIImage(systemName: "square.and.arrow.up")
        //            tabViewButton.setImage(imageTabView, for: .normal)
        //            tabViewButton.setTitleColor(.blue, for: .normal)
        //
        //            // Use 'data' to configure the button, such as setting a title or other properties
        //            tabViewButton.setTitle(data.title, for: .normal)
        //            // Assuming 'data' contains the target action for the button
        //            tabViewButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        //
        //            drawerView.addSubview(tabViewButton)
        //
        //            // Update yOffset for the next button (if needed)
        //            yOffset += buttonHeight + spacing
        //        }
        
        //
        //        let menuButton = UIButton(frame: CGRect(x: reloadButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        //        let imageMenu = UIImage(systemName: "ellipsis")
        //        menuButton.setImage(imageMenu, for: .normal)
        //        menuButton.setTitleColor(.blue, for: .normal)
        //        drawerView.addSubview(menuButton)
        
        loadAndSetData()
        DispatchQueue.main.async { [self] in
            if let url = history.last?.url {
                webView.load(URLRequest(url: url))
            } else {
                webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
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
                //                UIAction(title: "Security", image: UIImage(systemName: "lock.fill"), handler: { (_) in
                //                    self.performSegue(withIdentifier: "securitySegue", sender: self)
                //                }),
                //                UIAction(title: "Extensions", image: UIImage(systemName: "puzzlepiece.extension"), handler: { (_) in
                //                    self.performSegue(withIdentifier: "ExtensionsSegue", sender: self)
                //                }),
                //                UIAction(title: "Themes", image: UIImage(systemName: "paintbrush"), handler: { (_) in
                //                    self.performSegue(withIdentifier: "ThemesSegue", sender: self)
                //                }),
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (_) in
                    if let urlString = self.webView.url?.absoluteString {
                        let message = "Check out this link:"
                        if let url = URL(string: urlString) {
                            let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    }
                }),
                UIAction(title: "Dark Mode", image: UIImage(systemName: "moon"), handler: { [self] (_) in
                    if lightmode == true {
                        if #available(iOS 13.0, *) {
                            overrideUserInterfaceStyle = .dark
                        } else {
                            //this is here so older versiosn don't crash
                        }
                        lightmode = false
                        print("Night Mode")
                    } else {
                        if #available(iOS 13.0, *) {
                            overrideUserInterfaceStyle = .light
                        } else {
                            //this is here so older versiosn don't crash
                        }
                        lightmode = true
                        print("Light Mode")
                    }
                }),
                //                UIAction(title: "Split View", image: UIImage(systemName: "square.bottomhalf.filled"), handler: { [self] (_) in
                //                    self.performSegue(withIdentifier: "splitView", sender: self)
                //                }),
                //                UIAction(title: "Find on Page", image: UIImage(systemName: "magnifyingglass"), handler: { (_) in
                //                    // Handle the action for the standard item
                //                }),
                //                UIAction(title: "Zoom", image: UIImage(systemName: "arrow.up.left.and.down.right.magnifyingglass"), handler: { (_) in
                //                    // Handle the action for the standard item
                //                }),
                //                UIAction(title: "Request Desktop Browsing", image: UIImage(systemName: "desktopcomputer"), handler: { (_) in
                //                    // Handle the action for the standard item
                //                }),
                UIAction(title: "Private Mode", image: UIImage(systemName: "eye.slash"), handler: { [self] (_) in
                    if privateMode == false {
                        privateMode = true
                        print("Private Mode")
                    } else {
                        privateMode = false
                        print("Public Mode")
                    }
                }),
                UIAction(title: "Add Bookmark", image: UIImage(systemName: "star"), handler: { (_) in
                    self.bookmarks.append(Bookmark(title: self.webView.title ?? "No Title", url: self.webView.url))
                    print("Adding Bookmark", self.webView.title ?? "No Title", self.webView.url?.absoluteString ?? "No URL")
                }),
                UIAction(title: "Bookmarks", image: UIImage(systemName: "book"), handler: { (_) in
                    self.performSegue(withIdentifier: "bookmarksSegue", sender: self)
                }),
                UIAction(title: "History", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { (_) in
                    self.loadAndSetData()
                    self.performSegue(withIdentifier: "historySegue", sender: self)
                }),
                UIAction(title: "Delete all data", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    self.deleteMenu()
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
    }
    
    func deleteMenu() {
        let alert = UIAlertController(title: "Delete All Data", message: "Would you like to delete all browsing data including; tabs, history, bookmarks, and cache.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                   self.history.removeAll()
                   self.tab.removeAll()
                   self.bookmarks.removeAll()
                   self.clearSaveData()
                   self.clearCache()
                   print("Deleting All Data")
                   let alert = UIAlertController(title: "Deleted", message: "All data has been deleted.", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
               }))
               self.present(alert, animated: true, completion: nil)
    }


    // Trigger the search when the Return key is pressed
    func textFieldShouldReturn(_ textInput: UITextField) -> Bool {
        textInput.resignFirstResponder() // Dismiss the keyboard
        if let searchText = textInput.text, !searchText.isEmpty {
            // Check if the input is a valid URL
            if let url = URL(string: searchText), url.scheme != nil {
                let request = URLRequest(url: url)
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("Opening URL", request)
                }
            }else if (searchText.contains(".") || searchText.contains("/") || searchText.contains(".com")) && !searchText.contains(" ") {
                let request = URLRequest(url: URL(string: "https://\(searchText)")!)
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("Opening URL", request)
                }
            }
         else {
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
    @IBAction func backButtonTapped() {
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
        if privateMode == true {
            
        } else {
            
            loadAndSetData()
            let newTab = Tab(url: webView.url, title: webView.title)
            tab.append(newTab)
            if let url = URL(string: "https://google.com") {
                let request = URLRequest(url: url)
                webView.load(request)
                webView.backForwardList.perform(Selector(("_removeAllItems")))
            }}
        
    }
    
    @IBAction func reloadWebView() {
        webView.reload()
        print("Reload")
    }
    
    
    func history(url: URL?) {
        if privateMode == true {
            
        } else {
            let historyTab = Tab(url: url, title: "")
            history.append(historyTab)
            for tab in history{
                print("History", tab.url!)
            }
        }
    }
    
    @IBAction func openTabView(){
        if privateMode == true {
            
        }else {
            if tab.contains(where: {$0.url == webView.url}) == false {
                let newTab = Tab(url: webView.url, title: webView.title)
                tab.append(newTab)
            }
            
            loadAndSetData()
            performSegue(withIdentifier: "tabViewSegue", sender: self)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        stopButton.isHidden = false
        reloadButton.isHidden = true
        progressBar.isHidden = false
        progressBar.setProgress(0.0, animated: false)
        print("Reload Button isHidden, loading wheel isShown")
    }
    @IBAction func stopLoading(_ sender: Any) {
        webView.stopLoading()
        stopButton.isHidden = true
        reloadButton.isHidden = false
        progressBar.isHidden = true
        progressBar.setProgress(0.0, animated: false)
        print("Reload Button isShown, loading wheel isHidden")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressBar.setProgress(0.5, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.progressBar.progress == 0.5 {
                self.progressBar.setProgress(0.65, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.progressBar.progress == 0.65 {
                        self.progressBar.setProgress(0.9, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if self.progressBar.progress == 0.9 {
                                self.progressBar.setProgress(0.95, animated: true)
                            }
                        }
                    
                    }
                
                }
            }
        }
    
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error){
        let alert = UIAlertController(title: "Failed", message: "Webpage failed to load.", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished Navigation")
        if let pageTitle = webView.title {
            textInput.text = pageTitle
            reloadButton.isHidden = false
            stopButton.isHidden = true
            if let urlString = webView.url?.absoluteString {
                print("URL: ", urlString)
                if let url = URL(string: urlString) {
                    history(url: url)
                }
            }
            saveData()
        }
        if lightmode == false {
            let cssString = "@media (prefers-color-scheme: dark) {body {color: white;}a:link {color: #0096e2;}a:visited {color: #9d57df;}}"
            let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }
        progressBar.setProgress(1.0, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.progressBar.isHidden = true
                }
        updateNavigationButtons()
    }
    
    func textFieldDidBeginEditing(_ textInput: UITextField) {
        textInput.selectedTextRange = textInput.textRange(from: textInput.beginningOfDocument, to: textInput.endOfDocument)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveData()
        print(segue.destination)
        if let destination = segue.destination as? HistoryDelegate {
            print("good")
            for tab in self.history {
                let url = tab.url
                destination.didSelectHistory(url: url!)
                print("Url preparing to transfer", url!)
            }
        }
        if let destination = segue.destination as? TabDelegate {
            print("tab good")
            for tab in self.tab {
                let url = tab.url
                let title = tab.title
                destination.didSelectTabView(url: url!, title: title!)
                print("Preparing to transfer to tab view: ", url!, " With title: ", title)
            }
        }
        if let destination = segue.destination as? BookmarkDelegate {
            print("bookmark good")
            for bookmark in self.bookmarks {
                let url = bookmark.url
                let title = bookmark.title
                destination.didSelectBookmark(url: url!, title: title!)
            }
        }
    }
    
    @IBAction func goBackToLastTab(segue: UIStoryboardSegue){
        loadAndSetData()
        let tabCount = tab.count
        print(tab.count)
        if tabCount > 0 {
            let lastTab = tab[tabCount - 1]
            let lastTabUrl = lastTab.url
            let request = URLRequest(url: lastTabUrl!)
            webView.load(request)
            saveData()
        }
    }
    
    @IBAction func pullDown(_ sender: Any) {
        print("pull down")
        webView.reload()
    }
    
    func retrieveData() -> [Tab] {
        let defaults = UserDefaults.standard
        if let encodedTabs = defaults.data(forKey: "tabData") {
            let decoder = JSONDecoder()
            if let decodedTabs = try? decoder.decode([Tab].self, from: encodedTabs) {
                return decodedTabs
            }
        }
        return []
    }
    
    func retrieveDataHistory() -> [Tab]
    {
        let defaults = UserDefaults.standard
        if let encodedHistory = defaults.data(forKey: "historyData") {
            let decoder = JSONDecoder()
            if let decodedHistory = try? decoder.decode([Tab].self, from: encodedHistory) {
                return decodedHistory
            }
        }
        return []
    }
    func retrieveDataBookmarks() -> [Bookmark]
    {
        let defaults = UserDefaults.standard
        if let encodedBookmarks = defaults.data(forKey: "bookmarkData") {
            let decoder = JSONDecoder()
            if let decodedBookmarks = try? decoder.decode([Bookmark].self, from: encodedBookmarks) {
                return decodedBookmarks
            }
        }
        return []
    }
    func retrieveSelectedTabData() -> [Tab]{
        let defaults = UserDefaults.standard
        if let encodedSelectedTab = defaults.data(forKey: "selectedTabData") {
            let decoder = JSONDecoder()
            if let decodedSelectedTab = try? decoder.decode([Tab].self, from: encodedSelectedTab) {
                return decodedSelectedTab
            }
        }
        return []
    }
    
    
    
    func loadAndSetData() {
        let savedTabs = retrieveData()
        let savedHistory = retrieveDataHistory()
        let savedBookmarks = retrieveDataBookmarks()
        tab = savedTabs
        history = savedHistory
        bookmarks = savedBookmarks
    }

    func saveData() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedTab = try? encoder.encode(tab) {
            defaults.set(encodedTab, forKey: "tabData")
            print("Tab data saved")
        }
        if let encodedHistory = try? encoder.encode(history) {
            defaults.set(encodedHistory, forKey: "historyData")
            print("History data saved")
        }
        if let encodedBookmarks = try? encoder.encode(bookmarks) {
            defaults.set(encodedBookmarks, forKey: "bookmarkData")
            print("Bookmark data saved")
        }
    }
    
    func clearSaveData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "tabData")
        defaults.removeObject(forKey: "historyData")
        defaults.removeObject(forKey: "bookmarkData")
    }
    
    func clearCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }

//    //To reduce data save this instead of refetching it every time
//    func updateAdBlockArray(){
//        let url = URL(string: "https://hosts.anudeep.me/mirror/adservers.txt")!
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            if let data = data {
//                let dataString = String(data: data, encoding: .utf8)
//                let lines = dataString!.split(separator: "\n")
//                for line in lines {
//                    if !line.starts(with: "#") {
//                        self.adBlockArray.append(String(line))
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
}



    
