//
//  ProfileModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IAppUser {
    var name: String? { get set }
    var about: String? { get set }
    var picture: UIImage? { get set }
}

protocol IAppUserModel: IAppUser, IKeyboardModel {
    func set(on profile: IAppUser)
    
    func load(_ completion: @escaping (IAppUser?) -> ())
    func save(_ completion: @escaping (Bool) -> ())
}

class Profile: IAppUser {
    
    var name, about: String?
    var picture: UIImage?
    
    init(name: String? = nil, about: String? = nil, picture: UIImage? = nil) {
        self.name = name
        self.about = about
        self.picture = picture
    }
    
}

class ProfileModel: IAppUserModel {
    
    var name, about: String?
    var picture: UIImage?
    
    private let dataService: IDataManager
    private var keyboardService: IKeyboardService
    
    init(dataService: IDataManager, keyboardService: IKeyboardService,
         name: String? = nil, about: String? = nil, picture: UIImage? = nil) {
        self.dataService = dataService
        self.keyboardService = keyboardService
        
        self.name = name
        self.about = about
        self.picture = picture
    }
    
    func set(on profile: IAppUser) {
        self.name = profile.name
        self.about = profile.about
        self.picture = profile.picture
    }
    
    // MARK: - IDataService
    
    func load(_ completion: @escaping (IAppUser?) -> ()) {
        dataService.loadAppUser(completion: completion)
    }
    
    func save(_ completion: @escaping (Bool) -> ()) {
        dataService.saveAppUser(self, completion: completion)
    }
    
    // MARK: - IKeyboardService
    
    func setKeyboardDelegate(_ delegate: UIView?) {
        keyboardService.delegate = delegate
    }
    
    func turnKeyboard(on: Bool) {
        keyboardService.turnKeyboard(on: on)
    }
    
}
