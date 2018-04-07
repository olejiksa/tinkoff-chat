//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/02/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var gcdButton: UIButton!
    @IBOutlet private weak var operationButton: UIButton!
    @IBOutlet private weak var progressRing: UIActivityIndicatorView!
    @IBOutlet private weak var editButton: UIButton!
    
    @IBOutlet var userPictureImageView: UIImageView! {
        didSet {
            userPictureImageView.layer.masksToBounds = true
            userPictureImageView.layer.cornerRadius = cameraButton.frame.width / 2
        }
    }
    
    @IBOutlet var cameraButton: UIButton! {
        didSet {
            cameraButton.layer.cornerRadius = cameraButton.frame.width / 2
        }
    }
    
    @IBOutlet var usernameTextField: UITextField! {
        didSet {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: usernameTextField.frame.height))
            usernameTextField.leftView = paddingView
            usernameTextField.rightView = paddingView
            usernameTextField.leftViewMode = .always
            usernameTextField.rightViewMode = .always
            usernameTextField.layer.masksToBounds = true
            usernameTextField.layer.cornerRadius = 5
            usernameTextField.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            usernameTextField.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var aboutTextView: UITextView! {
        didSet {
            aboutTextView.layer.cornerRadius = 5
            aboutTextView.layer.borderWidth = 1
            aboutTextView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    @IBOutlet var saveButtonBar: UIStackView! {
        didSet {
            saveButtonBar.isHidden = true
        }
    }
    
    var dataManager: DataManager = StorageManager()
    var profile = Profile()
    
    var changesToSave: Bool {
        return profile.name != usernameTextField.text ||
            profile.about != aboutTextView.text ||
            profile.picture != userPictureImageView.image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        applyCustomButtonStyle(for: editButton, gcdButton, operationButton)
        
        progressRing.startAnimating()
        
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        aboutTextView.delegate = self
        
        editButton.isUserInteractionEnabled = false
        editButton.alpha = 0.5
        
        dataManager.loadProfile { [weak self] profile, error in
            guard error == nil, let profile = profile else {
                self?.editButton.isUserInteractionEnabled = true
                self?.editButton.alpha = 1
                self?.progressRing.stopAnimating()
                return
            }
            
            self?.profile = profile
            
            if let name = profile.name {
                self?.usernameTextField.text = name
            }
            
            if let about = profile.about {
                self?.aboutTextView.text = about
            }
            
            if let picture = profile.picture {
                self?.userPictureImageView.image = picture
            }
            
            self?.editButton.isUserInteractionEnabled = true
            self?.editButton.alpha = 1
            self?.progressRing.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        view.gestureRecognizers?.removeAll()
    }
    
    @IBAction func choosePicture() {
        view.endEditing(true)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: { _ in
            self.makeAction(.photoLibrary, appeal: "галерее")
        }))
        actionSheet.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { _ in
            self.makeAction(.camera, appeal: "камере")
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func didCloseBarButtonItemTap() {
        dismiss(animated: true)
    }
    
    @IBAction func didEditButtonTap() {
        saveButtonBar.isHidden = false
        editButton.isHidden = true
        
        cameraButton.isUserInteractionEnabled = true
        cameraButton.alpha = 1
        usernameTextField.isUserInteractionEnabled = true
        
        usernameTextField.layer.borderColor = #colorLiteral(red: 0.7294117647, green: 0.7294117647, blue: 0.7294117647, alpha: 1)
        
        aboutTextView.isEditable = true
        aboutTextView.layer.borderColor = #colorLiteral(red: 0.7294117647, green: 0.7294117647, blue: 0.7294117647, alpha: 1)
    }
    
    @IBAction func didSaveButtonTap(_ sender: UIButton) {
        /* switch sender.tag {
        case 1:
            dataManager = gcdDataManager
        case 2:
            dataManager = operationDataManager
        default:
            return
        } */
        
        view.endEditing(true)
        progressRing.startAnimating()
        makeSaveButtons(active: false)
        
        if usernameTextField.text != profile.name {
            profile.name = usernameTextField.text
        }
        
        if aboutTextView.text != profile.about {
            profile.about = aboutTextView.text
        }
        
        if userPictureImageView.image != profile.picture {
            profile.picture = userPictureImageView.image
        }
        
        dataManager.saveProfile(profile) { [weak self] error in
            if error == nil {
                let alert = UIAlertController(title: nil, message: "Данные сохранены", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self?.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { _ in
                    self?.didSaveButtonTap(sender)
                }))
                
                self?.present(alert, animated: true)
            }
            
            self?.progressRing.stopAnimating()
            
            self?.saveButtonBar.isHidden = true
            self?.editButton.isHidden = false
            
            self?.usernameTextField.isUserInteractionEnabled = false
            self?.cameraButton.isUserInteractionEnabled = false
            self?.cameraButton.alpha = 0.5
            
            self?.aboutTextView.isEditable = false
            
            self?.usernameTextField.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self?.aboutTextView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y >= 0 {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y += keyboardSize.height
        }
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func applyCustomButtonStyle(for buttons: UIButton...) {
        for eachButton in buttons {
            eachButton.layer.borderWidth = 2
            eachButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            eachButton.layer.cornerRadius = 15
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    func makeAction(_ sourceType: UIImagePickerControllerSourceType, appeal: String) {
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
    
    func authorize(using sourceType: UIImagePickerControllerSourceType) {
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
    
    func openImagePicker(using sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func makeSaveButtons(active: Bool) {
        gcdButton.alpha = active ? 1: 0.5
        operationButton.alpha = active ? 1: 0.5
        gcdButton.isUserInteractionEnabled = active
        operationButton.isUserInteractionEnabled = active
    }
    
}

extension ProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        makeSaveButtons(active: changesToSave)
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        makeSaveButtons(active: changesToSave)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        userPictureImageView.image = image
        makeSaveButtons(active: changesToSave)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
