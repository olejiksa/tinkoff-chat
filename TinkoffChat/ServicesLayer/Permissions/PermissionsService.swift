//
//  PermissionsService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Photos
import UIKit

protocol IPermissionsDelegate: class {
    func showErrorMessage(_ message: String)
    func openImagePicker(using sourceType: UIImagePickerControllerSourceType)
}

protocol IPermissions {
    func makeAction(_ sourceType: UIImagePickerControllerSourceType, appeal: String)
    func authorize(using sourceType: UIImagePickerControllerSourceType)
}

protocol IPermissionsModel: IPermissions {
    func setPermissionsDelegate(_ delegate: IPermissionsDelegate?)
}

protocol IPermissionsService: class, IPermissions {
    var delegate: IPermissionsDelegate? { get set }
}

class PermissionsService: IPermissionsService {
    
    weak var delegate: IPermissionsDelegate?
    
    func makeAction(_ sourceType: UIImagePickerControllerSourceType, appeal: String) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            delegate?.showErrorMessage("Данное устройство не имеет доступа к \(appeal).")
            return
        }
        
        let status: Int
        
        switch sourceType {
        case .camera:
            status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video).rawValue
        case .photoLibrary:
            status = PHPhotoLibrary.authorizationStatus().rawValue
        default:
            return
        }
        
        switch status {
        case 0:
            authorize(using: sourceType)
        case 1:
            delegate?.showErrorMessage("Доступ к \(appeal) ограничен операционной системой.")
        case 2:
            delegate?.showErrorMessage("Пожалуйста, убедитесь в том, что приложение имеет доступ к \(appeal) в настройках приватности.")
        case 3:
            delegate?.openImagePicker(using: sourceType)
        default:
            break
        }
    }
    
    func authorize(using sourceType: UIImagePickerControllerSourceType) {
        if sourceType == .photoLibrary {
            PHPhotoLibrary.requestAuthorization({ [weak self] response in
                if response == .authorized {
                    self?.delegate?.openImagePicker(using: sourceType)
                }
            })
        } else if sourceType == .camera {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
                if response {
                    self?.delegate?.openImagePicker(using: sourceType)
                }
            }
        }
    }
    
}
