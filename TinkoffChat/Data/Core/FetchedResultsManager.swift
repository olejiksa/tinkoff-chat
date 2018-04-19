//
//  FetchedResultsManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 16/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

class FetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate {
    
    var delegate: ConversationDelegate?
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.delegate?.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        DispatchQueue.main.async {
            switch type {
            case .delete:
                self.delegate?.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .insert:
                self.delegate?.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .move:
                self.delegate?.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
                self.delegate?.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .update:
                self.delegate?.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    self.delegate?.deleteRows(at: [indexPath], with: .automatic)
                }
            case .insert:
                if let newIndexPath = newIndexPath {
                    self.delegate?.insertRows(at: [newIndexPath], with: .automatic)
                }
            case .move:
                if let indexPath = indexPath {
                    self.delegate?.deleteRows(at: [indexPath], with: .automatic)
                }
                
                if let newIndexPath = newIndexPath {
                    self.delegate?.insertRows(at: [newIndexPath], with: .automatic)
                }
            case .update:
                if let indexPath = indexPath {
                    self.delegate?.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.delegate?.endUpdates()
        }
    }
    
}
