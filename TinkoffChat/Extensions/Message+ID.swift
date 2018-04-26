//
//  Message+ID.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 11/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

extension Message: MessageCellConfiguration {
    
    @nonobjc class func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)"
               .data(using: .utf8)!.base64EncodedString()
    }
    
}
