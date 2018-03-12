//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/02/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet private weak var userPictureImageView: UIImageView!
    @IBOutlet private weak var choosePictureButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        choosePictureButton.layer.cornerRadius = choosePictureButton.frame.width / 2.0
        
        userPictureImageView.layer.masksToBounds = true
        userPictureImageView.layer.cornerRadius = choosePictureButton.frame.width / 2.0
        
        editButton.layer.borderWidth = 2
        editButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        editButton.layer.cornerRadius = 15
        
        //print(editButton.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // print(editButton.frame)
        // It doesn't work because view is not loaded yet
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* Во viewDidLoad берутся значения,
         аналогичные сториборду (Interface Builder)
         (она загружена, но реальный экран мы не знаем),
         а после появления вью на экране устройстве -
         значения, относящиеся к вью на нем - вычисленные в AutoLayout */
        //print(editButton.frame)
    }
    
    @IBAction private func choosePicture() {
        //print("Выбери изображение профиля")
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: { (alert: UIAlertAction!) in
            self.makeAction(.photoLibrary, appeal: "галерее")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { (alert: UIAlertAction!) in
            self.makeAction(.camera, appeal: "камере")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func makeAction(_ sourceType: UIImagePickerControllerSourceType, appeal: String) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showErrorMessage("Данное устройство не имеет доступа к \(appeal).")
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
            showErrorMessage("Доступ к \(appeal) ограничен операционной системой.")
        case 2:
            showErrorMessage("Пожалуйста, убедитесь в том, что приложение имеет доступ к \(appeal) в настройках приватности.")
        case 3:
            openImagePicker(using: sourceType)
        default:
            break
        }
    }
    
    private func authorize(using sourceType: UIImagePickerControllerSourceType) {
        if sourceType == .photoLibrary {
            PHPhotoLibrary.requestAuthorization({ response in
                if response == .authorized {
                    self.openImagePicker(using: sourceType)
                }
            })
        } else if sourceType == .camera {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.openImagePicker(using: sourceType)
                }
            }
        }
    }
    
    private func openImagePicker(using sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction private func didCloseBarButtonItemTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        userPictureImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
    }
}
