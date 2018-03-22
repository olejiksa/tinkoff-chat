//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 11/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell, MessageCellConfiguration {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var messageText: String? {
        didSet {
            messageLabel.text = messageText
        }
    }
    
    var isIncoming = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.superview?.layer.cornerRadius = messageLabel.frame.height / 2
    }

}
