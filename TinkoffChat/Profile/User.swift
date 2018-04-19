//
//  User.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 18/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

extension User {
    
    @nonobjc class func withId(userId: String) -> User? {
        guard let fetchRequest: NSFetchRequest<User> = CoreDataService.shared.fetchRequest(.userWithId, substitutionDictionary: ["userId": userId]) else {
            return nil
        }
        
        return CoreDataService.shared.fetch(fetchRequest)?.first
    }
    
}
