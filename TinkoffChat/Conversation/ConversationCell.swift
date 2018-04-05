//
//  ConversationCell.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell, ConversationCellConfiguration {
    var name: String? {
        didSet {
            nameLabel.text = name ?? "Name"
        }
    }
    
    var lastMessageText: String? {
        didSet {
            messageLabel.text = lastMessageText ?? "No messages yet"
            updateFont()
        }
    }
    
    var date: Date? {
        didSet {
            formatDate()
        }
    }
    
    var online = false {
        didSet {
            backgroundColor = online ? #colorLiteral(red: 1, green: 0.9960784314, blue: 0.8078431373, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    var hasUnreadMessages = false {
        didSet {
            updateFont()
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private func updateFont() {
        if lastMessageText == nil {
            messageLabel.font = .italicSystemFont(ofSize: 14)
        } else if hasUnreadMessages {
            messageLabel.font = .boldSystemFont(ofSize: 14)
        } else {
            messageLabel.font = .systemFont(ofSize: 14)
        }
    }
    
    private func formatDate() {
        guard let date = date else {
            dateLabel.text = "Date"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "HH:mm" : "dd MMM"
        
        dateLabel.text = dateFormatter.string(from: date)
    }
}
