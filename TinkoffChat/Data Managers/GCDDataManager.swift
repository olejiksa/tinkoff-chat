//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class GCDDataManager: DataManager {
    func loadProfile(completion: @escaping (Profile?, Error?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let profile = try Profile.read(filenames: (name: "name.txt", about: "about.txt", picture: "picture.jpg"))

                DispatchQueue.main.async {
                    completion(profile, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func saveProfile(_ profile: Profile, completion: @escaping (Error?) -> ()) {
        DispatchQueue(label: "com.olejiksa.customSerial", qos: .userInitiated).async {
            do {
                try Profile.write(profile, filenames: (name: "name.txt", about: "about.txt", picture: "picture.jpg"))

                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
