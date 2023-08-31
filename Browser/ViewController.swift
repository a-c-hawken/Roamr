import UIKit
import DrawerView
import WebKit

protocol HistoryDelegate {
    func didSelectHistory(url: URL)
}

protocol BookmarkDelegate {
    func didSelectBookmark(url: URL, title: String)
}


class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UITableViewDataSource, UITableViewDelegate, DrawerViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tab.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reversedIndex = tab.count - 1 - indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if tab.count > 0 {
            cell.textLabel?.text = tab[reversedIndex].title
            cell.backgroundColor = UIColor.clear
        }
        self.loadBookmark()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reversedIndex = tab.count - 1 - indexPath.row
        if let url = tab[reversedIndex].url {
            let currentTab = Tab(url: url, title: tab[reversedIndex].title)
            tab.append(currentTab)
            webView.load(URLRequest(url: url))
            tableView.deselectRow(at: indexPath, animated: true)
            //delete the tab item at select row
            tab.remove(at: reversedIndex)
            drawerView?.setPosition(.collapsed, animated: true)
        }
    }
    
    //delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let reversedIndex = tab.count - 1 - indexPath.row
        if editingStyle == .delete {
            tab.remove(at: reversedIndex)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    func didSelectTabView(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        print ("recieved and loaded url: ", request.url!.absoluteString)
    }
    
    func cacheWebsite(){
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            //show onboarding
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    
    var backButton: UIButton!
    var forwardButton: UIButton!
    var newTabButton: UIButton!
    //var menuButton: UIBarButtonItem!
    
    var stopButton: UIButton!
    var textInput: UITextField!
    
    var tableView: UITableView!
    var bookmarkTableView: UITableView!
    var reloadButton: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    
    var progressBar: UIProgressView!
    var drawerView: DrawerView!
    
    @IBOutlet weak var launchViewImage: UIImageView!
    
    
    var menuButton: UIButton!
    var lightmode: Bool = true
    var newWebView: WKWebView!
    var window: UIWindow?
    var adBlockArray: [String] = []
    var autoComplete: [String] = []
    
    var tab: [Tab] = []
    var history: [Tab] = []
    var bookmarks: [Bookmark] = []
    
    var privateMode: Bool = false
    
    var defaultSearchEngines: String = "https://www.google.com/search?q="
    var loadedBookmark: String = ""
    
    var bigPhone: Bool = false
    var spacing2: CGFloat = 0
    
    var cancelOnPurpose: Bool = false
    
    
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
    
    
    // Enable or disable the back and forward buttons based on the web view's navigation state
    func updateNavigationButtons() {
        if privateMode == true {}
        else {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
    }
    
    override func viewDidLoad() {
        //if phone width greater than 375, bigPhone = true
        if view.frame.width > 375 {
            bigPhone = true
        } else{
            bigPhone = false
        }
        self.loadDrawerView()
        self.hideWebView()
        self.clearCache()
        self.loadAndSetData()
        
        
        
        //menuButton.menu = mainMenu
        textInput.delegate = self
        webView.navigationDelegate = self
        updateNavigationButtons()
        progressBar.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.drawerView?.removeFromSuperview()
            self.loadDrawerView()
        }, completion: { context in
            print("rotated")
        })
    }
    
    
    
    func loadDrawerView(){
        drawerView = DrawerView()
        drawerView.attachTo(view: self.view)
        
        // Set up the drawer here
        drawerView.snapPositions = [.collapsed, .open]
        //drawerView color = default light/dark
        drawerView.backgroundColor = UIColor.white
        drawerView.delegate = self
        
        let xOffset: CGFloat = 10
        let yOffset: CGFloat = 10
        let buttonWidth = view.frame.width / 15
        let buttonHeight = buttonWidth + 5
        let spacing = view.frame.width / 35
        
        let maxwidth = view.frame.width - 20
        let image2 = UIImage(named: "Image")
        
        //progressBar
        progressBar = UIProgressView(frame: CGRect(x: xOffset, y: 0, width: maxwidth, height: buttonHeight + 20))
        progressBar.progressTintColor = UIColor.systemBlue
        progressBar.trackTintColor = UIColor.lightGray
        drawerView.addSubview(progressBar)
        
        
        backButton = UIButton(frame: CGRect(x: xOffset, y: yOffset, width: buttonWidth, height: buttonHeight))
        let imageBack = UIImage(systemName: "chevron.backward")
        backButton.setImage(imageBack, for: .normal)
        backButton.setTitleColor(.blue, for: .normal)
        drawerView.addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        
        newTabButton = UIButton(frame: CGRect(x: backButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        let imageNewTab = UIImage(systemName: "plus")
        newTabButton.setImage(imageNewTab, for: .normal)
        newTabButton.setTitleColor(.blue, for: .normal)
        drawerView.addSubview(newTabButton)
        
        newTabButton.addTarget(self, action: #selector(createNewTabButtonPressed), for: .touchUpInside)
        
        let shareButton = UIButton(frame: CGRect(x: newTabButton.frame.maxX + spacing, y: yOffset, width: buttonWidth, height: buttonHeight))
        let image = UIImage(systemName: "square.and.arrow.up")
        shareButton.setImage(image, for: .normal)
        shareButton.setTitleColor(.blue, for: .normal)
        drawerView.addSubview(shareButton)
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        textInput = UITextField(frame: CGRect(x: shareButton.frame.maxX + spacing, y: yOffset, width: maxwidth / 1.65, height: buttonHeight * 1.2))
        textInput.placeholder = "Search"
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: textInput.frame.height))
        textInput.leftView = leftPaddingView
        textInput.leftViewMode = .always
        
        textInput.font = UIFont.systemFont(ofSize: 15)
        textInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textInput.frame.height))
        textInput.borderStyle = UITextField.BorderStyle.none
        textInput.background = image2
        textInput.clearButtonMode = .whileEditing
        textInput.autocorrectionType = .no
        textInput.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        drawerView.addSubview(textInput)
        
        reloadButton = UIButton(frame: CGRect(x: textInput.frame.maxX + spacing - 5, y: yOffset, width: buttonWidth, height: buttonHeight))
        let imageReload = UIImage(systemName: "arrow.clockwise")
        reloadButton.setImage(imageReload, for: .normal)
        reloadButton.setTitleColor(.blue, for: .normal)
        drawerView.addSubview(reloadButton)
        
        reloadButton.addTarget(self, action: #selector(reloadWebView), for: .touchUpInside)
        
        stopButton = UIButton(frame: CGRect(x: textInput.frame.maxX + spacing - 5, y: yOffset, width: buttonWidth, height: buttonHeight))
        let imageStop = UIImage(systemName: "xmark")
        stopButton.setImage(imageStop, for: .normal)
        stopButton.setTitleColor(.blue, for: .normal)
        drawerView.addSubview(stopButton)
        
        stopButton.addTarget(self, action: #selector(stopLoading), for: .touchUpInside)
        
        
        //tableView contain each tab
        tableView = UITableView(frame: CGRect(x: xOffset, y: backButton.frame.maxY + spacing, width: maxwidth, height: view.frame.height - backButton.frame.maxY - spacing - 150))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        drawerView.addSubview(tableView)
        
        //        bookmarkTableView = UITableView(frame: CGRect(x: xOffset, y: tableView.frame.maxY + 10, width: maxwidth, height: 650))
        //        bookmarkTableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookmarkCell")
        //        bookmarkTableView.dataSource = self
        //        bookmarkTableView.delegate = self
        //        bookmarkTableView.backgroundColor = UIColor.clear
        //        drawerView.addSubview(bookmarkTableView)
        
        
        loadAndSetData()
        DispatchQueue.main.async { [self] in
            if let url = tab.last?.url {
                webView.load(URLRequest(url: url))
                addExistingTab()
                showWebView()
            } else {
                
            }
        }
        
        progressBar.progress = 0.0
        stopButton.isHidden = true
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: tableView.frame.maxY, width: view.frame.width, height: 60))
        drawerView.addSubview(toolbar)
        
        if bigPhone == false{
            spacing2 = view.frame.width / 6
            print(spacing2)
        } else {
            spacing2 = view.frame.width / 12
        }
        
        let settingsButton = UIButton(frame: CGRect(x: reloadButton.frame.minX - 10, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
        let imageSettings = UIImage(systemName: "ellipsis")
        settingsButton.setImage(imageSettings, for: .normal)
        settingsButton.setTitleColor(.black, for: .normal)
        settingsButton.backgroundColor = .clear
        drawerView.addSubview(settingsButton)
        
        let favouriteButton = UIButton(frame: CGRect(x: reloadButton.frame.minX - spacing2 - buttonWidth, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
        let imageStar = UIImage(systemName: "star")
        favouriteButton.setImage(imageStar, for: .normal)
        favouriteButton.setTitleColor(.black, for: .normal)
        favouriteButton.backgroundColor = .clear
        drawerView.addSubview(favouriteButton)
        
        favouriteButton.addTarget(self, action: #selector(addBookmark), for: .touchUpInside)
        
        //bookmark button
        let bookmarkButton = UIButton(frame: CGRect(x: favouriteButton.frame.minX - spacing2 - buttonWidth, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
        let imageBookmark = UIImage(systemName: "book")
        bookmarkButton.setImage(imageBookmark, for: .normal)
        bookmarkButton.setTitleColor(.black, for: .normal)
        bookmarkButton.backgroundColor = .clear
        drawerView.addSubview(bookmarkButton)
        bookmarkButton.addTarget(self, action: #selector(openBookmarks), for: .touchUpInside)
        
        //history button
        let historyButton = UIButton(frame: CGRect(x: bookmarkButton.frame.minX - spacing2 - buttonWidth, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
        let imageHistory = UIImage(systemName: "clock.arrow.circlepath")
        historyButton.setImage(imageHistory, for: .normal)
        historyButton.setTitleColor(.black, for: .normal)
        historyButton.backgroundColor = .clear
        drawerView.addSubview(historyButton)
        
        historyButton.addTarget(self, action: #selector(openHistory), for: .touchUpInside)
        
        if bigPhone == true {
            //private button
            let privateButton = UIButton(frame: CGRect(x: historyButton.frame.minX - spacing2 - buttonWidth, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
            let imagePrivate = UIImage(systemName: "eye.slash")
            privateButton.setImage(imagePrivate, for: .normal)
            privateButton.setTitleColor(.black, for: .normal)
            privateButton.backgroundColor = .clear
            drawerView.addSubview(privateButton)
            
            privateButton.addTarget(self, action: #selector(enablePrivate), for: .touchUpInside)
            
            //zoom
            let zoomButton = UIButton(frame: CGRect(x: privateButton.frame.minX - spacing2 - buttonWidth, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
            let imageZoom = UIImage(systemName: "plus.magnifyingglass")
            zoomButton.setImage(imageZoom, for: .normal)
            zoomButton.setTitleColor(.black, for: .normal)
            zoomButton.backgroundColor = .clear
            
            let zoomMenu = UIMenu(title: "Zoom", children: [
                UIAction(title: "Zoom In", image: UIImage(systemName: "plus.magnifyingglass"), handler: { (_) in
                    self.webView.scrollView.zoomScale += 0.5
                }),
                //reset
                UIAction(title: "Reset Zoom", image: UIImage(systemName: "magnifyingglass"), handler: { (_) in
                    self.webView.scrollView.zoomScale = 1
                }),
                
                UIAction(title: "Zoom Out", image: UIImage(systemName: "minus.magnifyingglass"), handler: { (_) in
                    self.webView.scrollView.zoomScale -= 0.5
                })
            ])
            zoomButton.showsMenuAsPrimaryAction = true
            zoomButton.menu = zoomMenu
            drawerView.addSubview(zoomButton)
        }
        
        //forward button
        forwardButton = UIButton(frame: CGRect(x: backButton.frame.minX, y: tableView.frame.maxY + 5, width: buttonWidth + 20, height: buttonHeight + 20))
        let imageForward = UIImage(systemName: "chevron.right")
        forwardButton.setImage(imageForward, for: .normal)
        forwardButton.setTitleColor(.black, for: .normal)
        forwardButton.backgroundColor = .clear
        drawerView.addSubview(forwardButton)
        
        forwardButton.addTarget(self, action: #selector(forwardButtonTap), for: .touchUpInside)
        
        
        
        
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
                UIAction(title: "Dark Mode", image: UIImage(systemName: "moon"), handler: { [self] (_) in
                    if lightmode == true {
                        if #available(iOS 13.0, *) {
                            overrideUserInterfaceStyle = .dark
                        } else {
                            //this is here so older versions don't crash
                        }
                        lightmode = false
                        print("Night Mode")
                    } else {
                        if #available(iOS 13.0, *) {
                            overrideUserInterfaceStyle = .light
                        } else {
                            //this is here so older versions don't crash
                        }
                        lightmode = true
                        print("Light Mode")
                    }
                }),
                //                UIAction(title: "Split View", image: UIImage(systemName: "square.bottomhalf.filled"), handler: { [self] (_) in
                //                    self.performSegue(withIdentifier: "splitView", sender: self)
                //                }),
                UIAction(title: "Find on Page", image: UIImage(systemName: "magnifyingglass"), handler: { (_) in
                    self.findOnPage()
                }),
                //                UIAction(title: "Request Desktop Browsing", image: UIImage(systemName: "desktopcomputer"), handler: { (_) in
                //                }),
                UIAction(title: "Delete all data", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    self.deleteMenu()
                })
            ]
        }
        
        settingsButton.menu = UIMenu(title: "", children: menuItems)
        settingsButton.showsMenuAsPrimaryAction = true
    }
    
    @objc func openBookmarks(){
        self.loadAndSetData()
        self.performSegue(withIdentifier: "bookmarksSegue", sender: self)
    }
    
    @objc func openHistory(){
        self.loadAndSetData()
        self.performSegue(withIdentifier: "historySegue", sender: self)
    }
    @objc func enablePrivate(){
        if privateMode == false {
            privateMode = true
            print("Private Mode")
        } else {
            privateMode = false
            print("Public Mode")
        }
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
    
    func addExistingTab(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if self.tab.contains(where: {$0.url == self.webView.url}) {
                print("Tab already exists")
                //delete current tab from array
                tab.removeAll(where: {$0.url == webView.url})
            }
        }}
    
    
    func tempAddOpenTab(){
        //add current tab temp to array
        print("tempAddOpenTab")
        if tab.count == 0 {
            tab.append(Tab(url: webView.url, title: webView.title ?? "No Title"))
            print("Adding Tab", webView.title ?? "No Title", webView.url?.absoluteString ?? "No URL")
            self.tableView.reloadData()
        }
        else if webView.canGoBack == true {
            tab.removeLast()
            tab.append(Tab(url: webView.url, title: webView.title ?? "No Title"))
            print("Adding Tab", webView.title ?? "No Title", webView.url?.absoluteString ?? "No URL")
            self.tableView.reloadData()
        } else {
            tab.append(Tab(url: webView.url, title: webView.title ?? "No Title"))
            print("Adding Tab", webView.title ?? "No Title", webView.url?.absoluteString ?? "No URL")
            self.tableView.reloadData()
        }
    }
    
    func findOnPage(){
        let alert = UIAlertController(title: "Find on Page", message: "Enter the text you would like to find on the page.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Text"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Find", style: .default, handler: { [self] _ in
            if let text = alert.textFields?[0].text {
                webView.find(text) { (result) in
                    if result.matchFound {
                        print("Match found")
                        self.drawerView?.setPosition(.collapsed, animated: true)
                        let alert = UIAlertController(title: "Match Found", message: "A match was found for the text you entered.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("No match found")
                        self.drawerView?.setPosition(.collapsed, animated: true)
                        let alert = UIAlertController(title: "No Match Found", message: "No matches were found for the text you entered.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Trigger the search when the Return key is pressed
    func textFieldShouldReturn(_ textInput: UITextField) -> Bool {
        showWebView()
        textInput.resignFirstResponder() // Dismiss the keyboard
        if let searchText = textInput.text, !searchText.isEmpty {
            // Check if the input is a valid URL
            if let url = URL(string: searchText), url.scheme != nil {
                let request = URLRequest(url: url)
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("Opening URL", request)
                    self.drawerView?.setPosition(.collapsed, animated: true)
                }
            }else if (searchText.contains(".") || searchText.contains("/") || searchText.contains(".com")) && !searchText.contains(" ") {
                let request = URLRequest(url: URL(string: "https://\(searchText)")!)
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("Opening URL", request)
                    self.drawerView?.setPosition(.collapsed, animated: true)
                }
            }
            else {
                let textSearch = searchText.replacingOccurrences(of: " ", with: "+")
                let textSearch2 = textSearch.replacingOccurrences(of: "-+Google+Search", with: " ")
                let urlString = "https://www.google.com/search?q=\(textSearch2)"
                //                autoCompleteResults()
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                        print("Searching", request)
                        self.drawerView?.setPosition(.collapsed, animated: true)
                    }
                }
            }
        }
        updateNavigationButtons()
        return true
    }
    
    // Go back to the previous web page
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
            print("Go Back")
        }
    }
    
    @objc func forwardButtonTap(){
        if webView.canGoForward {
            webView.goForward()
            print("Go Forward")
        }
    }
    
    @objc func createNewTabButtonPressed(_ sender: UIButton) {
        if privateMode == true {
            
        } else {
            cacheWebsite()
            loadAndSetData()
            tableView.reloadData()
            //            if let url = URL(string: "https://google.com") {
            //                let request = URLRequest(url: url)
            //                webView.load(request)ß
            if webView.isLoading {
                webView.stopLoading()
            }
            progressBar.progress = 0.0
            webView.backForwardList.perform(Selector(("_removeAllItems")))
            textInput.text = ""
            if webView.isHidden == false{hideWebView()}
        }
        //        }
    }
    
    @objc func reloadWebView() {
        webView.reload()
        print("Reload")
    }
    
    @objc func addBookmark(){
        self.bookmarks.append(Bookmark(title: self.webView.title ?? "No Title", url: self.webView.url))
        self.saveData()
        print("Adding Bookmark", self.webView.title ?? "No Title", self.webView.url?.absoluteString ?? "No URL")
    }
    func history(url: URL?) {
        if privateMode == true {
            
        } else {
            let historyTab = Tab(url: url, title: "")
            history.append(historyTab)
            //            for tab in history{
            //                print("History", tab.url!)
            //            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showWebView()
        stopButton.isHidden = false
        reloadButton.isHidden = true
        progressBar.isHidden = false
        progressBar.setProgress(0.0, animated: false)
        print("Reload Button isHidden, loading wheel isShown")
    }
    @objc func stopLoading(_ sender: Any) {
        webView.stopLoading()
        stopButton.isHidden = true
        reloadButton.isHidden = false
        progressBar.isHidden = true
        progressBar.setProgress(0.0, animated: false)
        print("Reload Button isShown, loading wheel isHidden")
    }
    
    @objc func shareButtonTapped(){
        if let urlString = self.webView.url?.absoluteString {
            let message = "Check out this link:"
            if let url = URL(string: urlString) {
                let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
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
    
    func failed() {
        if cancelOnPurpose == true{
            cancelOnPurpose = false
        }else{
            let alert = UIAlertController(title: "Failed", message: "Webpage failed to load.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (action) in
                self.webView.goBack()
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error){
        failed()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        failed()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished Navigation")
        tempAddOpenTab()
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
        cancelOnPurpose = true
        if webView.isLoading{
            webView.stopLoading()
        }
        progressBar.setProgress(0.0, animated: true)
        drawerView?.setPosition(.open, animated: true)
        textInput.selectedTextRange = textInput.textRange(from: textInput.beginningOfDocument, to: textInput.endOfDocument)
        //        if let urlString = webView.url?.absoluteString {
        //            textInput.text = urlString
        //            textInput.selectedTextRange = textInput.textRange(from: textInput.beginningOfDocument, to: textInput.endOfDocument)
        //        }
    }
    
    func textFieldDidEndEditing(_ textInput: UITextField) {
        drawerView?.setPosition(.collapsed, animated: true)
        textInput.resignFirstResponder()
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
        if let destination = segue.destination as? BookmarkDelegate {
            print("bookmark good")
            for bookmark in self.bookmarks {
                let url = bookmark.url
                let title = bookmark.title
                destination.didSelectBookmark(url: url!, title: title!)
            }
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
    func retrieveSelectedBookmarkData() -> [Bookmark]{
        let defaults = UserDefaults.standard
        if let encodedSelectedBookmark = defaults.data(forKey: "selectedBookmarkData") {
            let decoder = JSONDecoder()
            if let decodedSelectedBookmark = try? decoder.decode([Bookmark].self, from: encodedSelectedBookmark) {
                return decodedSelectedBookmark
            }
        }
        return []
    }
    //    func retrieveSearchEngine(){
    //        let defaults = UserDefaults.standard
    //
    //    }
    
    func hideDrawerView(){
        drawerView?.setPosition(.closed, animated: true)
    }
    func showDrawerView(){
        drawerView?.setPosition(.collapsed, animated: true)
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
    
    func hideWebView() {
        webView.isHidden = true
        launchViewImage.isHidden = false
    }
    
    func showWebView() {
        webView.isHidden = false
        launchViewImage.isHidden = true
    }
    
    func loadBookmark(){
        if loadedBookmark != "" {
            let url = URL(string: loadedBookmark)
            let request = URLRequest(url: url!)
            webView.load(request)
            loadedBookmark = ""
        }
    }
    
    func autoCompleteResult(){
        let urlSearch = textInput.text!.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://www.google.com/complete/search?client=chrome&q=\(urlSearch)")!
        print(url)
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
    
    @objc func textFieldChanged(_ sender: UITextField) {
        self.autoCompleteResult()
    }
}
    class Core {
        static let shared = Core()
        
        func isNewUser() -> Bool{
            return !UserDefaults.standard.bool(forKey: "isNewUser")
        }
        
        func setIsNotNewUser(){
            UserDefaults.standard.set(true, forKey: "isNewUser")
        }
    }

