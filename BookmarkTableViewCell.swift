//
//  BookmarkTableViewCell.swift
//  Roamr
//
//  Created by Aydan Hawken on 20/07/23.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
