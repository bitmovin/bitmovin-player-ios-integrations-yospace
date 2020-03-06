//
//  AdDetailCellTableViewCell.swift
//  Tub
//
//  Created by aneurinc on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var entryOneLabel: UILabel!
    @IBOutlet weak var entryTwoLabel: UILabel!
    @IBOutlet weak var entryThreeLabel: UILabel!
    @IBOutlet weak var entryFourLabel: UILabel!

    func setItem(item: ListItem) {
        entryOneLabel.text = item.entryOne
        entryTwoLabel.text = item.entryTwo
        entryThreeLabel.text = item.entryThree
        entryFourLabel.text = item.entryFour
    }
}
