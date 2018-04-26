//
//  UITableView+Updates.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 16/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IDataProviderDelegate: class {
    func beginUpdates()
    func endUpdates()
    
    func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
}

extension UITableView: IDataProviderDelegate {
    
    // Nothing else...
    // Just for UITableView usage as a IDataProviderDelegate protocol object
    
}
