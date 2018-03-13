//
//  DateExtension.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 10/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

extension Date {
    
    init?(from date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        guard let date = dateFormatter.date(from: date) else {
            return nil
        }
        
        self.init(timeInterval: 0, since: date)
    }
    
}
