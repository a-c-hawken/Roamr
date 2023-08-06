//
//  SettingsTableViewController.swift
//  Roamr
//
//  Created by Aydan Hawken on 20/07/23.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var engineButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    
    var appIconViewModel = ChangeAppIconViewModel()
    
    var url: String = "https://www.google.com/search?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        if(url == "https://www.google.com/search?q="){
            engineButton.setTitle("Google", for: .normal)
        } else if(url == "https://duckduckgo.com/?q="){
            engineButton.setTitle("DuckDuckGo", for: .normal)
        } else if(url == "https://www.bing.com/search?q="){
            engineButton.setTitle("Bing", for: .normal)
        } else if(url == "https://search.yahoo.com/search?p="){
            engineButton.setTitle("Yahoo", for: .normal)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Google", handler: { (_) in
                    self.url = "https://www.google.com/search?q="
                    self.engineButton.setTitle("Google", for: .normal)
                    self.setGoogle()
                
                }),
                UIAction(title: "DuckDuckGo", handler: { (_) in
                    self.url = "https://duckduckgo.com/?q="
                    self.engineButton.setTitle("DuckDuckGo", for: .normal)
                    self.setDuckDuckGo()
                
                }),
                UIAction(title: "Bing", handler: { (_) in
                    self.url = "https://www.bing.com/search?q="
                    self.engineButton.setTitle("Bing", for: .normal)
                    self.setBing()
                }),
                UIAction(title: "Yahoo", handler: { (_) in
                    self.url = "https://search.yahoo.com/search?p="
                    self.engineButton.setTitle("Yahoo", for: .normal)
                    self.setYahoo()
                
                }),
            ]}
        engineButton.menu = UIMenu(title: "Search Engine", children: menuItems)
        engineButton.showsMenuAsPrimaryAction = true
        
        var iconItems: [UIAction] {
            return [
            UIAction(title: "Dark", handler: { (_) in
                self.iconButton.setTitle("Dark", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .dark)
            }),
            UIAction(title: "Light", handler: { (_) in
                self.iconButton.setTitle("Light", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .lightMode)
            }),
            UIAction(title: "Dark Blue", handler: { (_) in
                self.iconButton.setTitle("Dark Blue", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .darkBlue)
            }),
            UIAction(title: "Ghost", handler: { (_) in
                self.iconButton.setTitle("Ghost", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .ghost)
            }),
            UIAction(title: "Lime", handler: { (_) in
                self.iconButton.setTitle("Lime", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .lime)
            }),
            UIAction(title: "Red", handler: { (_) in
                self.iconButton.setTitle("Red", for: .normal)
                self.appIconViewModel.updateAppIcon(to: .red)
            }),
            ]
        }
        iconButton.menu = UIMenu(title: "Icon", children: iconItems)
        iconButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    func setGoogle(){
        self.url = "https://www.google.com/search?q="
        saveSettings(self)
    }
    
    func setBing(){
        self.url = "https://www.bing.com/search?q="
        saveSettings(self)
    }
    
    func setDuckDuckGo(){
        self.url = "https://duckduckgo.com/?q="
        saveSettings(self)
    }
    
    func setYahoo(){
        self.url = "https://search.yahoo.com/search?p="
        saveSettings(self)
    }
    
    //save settings
    func saveSettings(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(url, forKey: "url")
        defaults.synchronize()
    }
    
    func loadSettings(){
        let defaults = UserDefaults.standard
        if let url = defaults.string(forKey: "url"){
            self.url = url
        }
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

final class ChangeAppIconViewModel: ObservableObject {
    @Published private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.rawValue else {
                /// No need to update since we're already using this icon.
                print("Updated")
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.rawValue)
            } catch {
                /// We're only logging the error here and not actively handling the app icon failure
                /// since it's very unlikely to fail.
                print("Updating icon to \(String(describing: icon.rawValue)) failed.")

                /// Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}

