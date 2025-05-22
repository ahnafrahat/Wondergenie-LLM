//
//  ResultTableViewCell.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
        
    @IBOutlet weak var shadowView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
