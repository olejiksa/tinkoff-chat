//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 11/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration {
    var messageText: String? { get set }
    var isIncoming: Bool { get set }
    var date: Date? { get set }
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var messageText: String? {
        didSet {
            messageLabel.text = messageText
        }
    }
    
    var isIncoming = false
    
    var date: Date? {
        didSet {
            formatDate()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.superview?.layer.cornerRadius = messageLabel.frame.height / 2
    }
    
    private func formatDate() {
        guard let date = date else {
            dateLabel.text = String()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "HH:mm" : "dd MMM"
        
        dateLabel.text = dateFormatter.string(from: date)
    }

}
