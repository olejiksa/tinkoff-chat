//
//  AppUserService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol IAppUserService: class {
    func loadAppUser(completion: @escaping (IAppUser?) -> ())
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ())
}
