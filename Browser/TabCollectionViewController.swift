//
//  TabCollectionViewController.swift
//  Aydan HawkWeb
//
//  Created by Aydan H on 14/06/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class TabTableViewController: UITableViewController, TabDelegate {
    
    class Tab {
        var url: URL?
        var title: String?
        // Add any additional properties as needed
        
        init(url: URL?, title: String?) {
            self.url = url
            self.title = title
        }
    }
    
    var tab: [Tab] = []
    
    func didSelectTabView(url: URL, title: String) {
        let newTab = Tab(url: url, title: title)
        tab.append(newTab)
        print ("recieved and saved url: ", newTab.url!.absoluteString, " title: ", newTab.title!)
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //demo tab
//        let tab = Tab(url: URL(string: "https://www.google.com"), title: "Google")
//        print("added", tab.url!.absoluteString)
//        self.tab.append(tab)
//        tableView.reloadData()
        
        

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tab.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tabCell", for: indexPath) as! TabTableViewCell
        print("made cell", tab[indexPath.row].url!.absoluteString)
        cell.title.text = tab[indexPath.row].url!.absoluteString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: TabTableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected", tab[indexPath.row].url!.absoluteString)
        self.dismiss(animated: true, completion: nil)
    }
    
}
