//
//  DataManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol DataManager {
    func loadProfile(completion: @escaping (Profile?, Error?) -> ())
    func saveProfile(_ profile: Profile, completion: @escaping (Error?) -> ())
}
