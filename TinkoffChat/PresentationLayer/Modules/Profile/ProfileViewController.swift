//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/02/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Photos
import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var progressRing: UIActivityIndicatorView!
    @IBOutlet private weak var editButton: UIButton!
    
    @IBOutlet private weak var userPictureImageView: UIImageView! {
        didSet {
            userPictureImageView.layer.masksToBounds = true
            userPictureImageView.layer.cornerRadius = cameraButton.frame.width / 2
        }
    }
    
    @IBOutlet private weak var cameraButton: UIButton! {
        didSet {
            cameraButton.layer.cornerRadius = cameraButton.frame.width / 2
        }
    }
    
    @IBOutlet private weak var usernameTextField: UITextField! {
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
    
    @IBOutlet private weak var aboutTextView: UITextView! {
        didSet {
            aboutTextView.layer.cornerRadius = 5
            aboutTextView.layer.borderWidth = 1
            aboutTextView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    // MARK: - Dependencies
    
    private var model: IAppUserModel
    
    // MARK: - Properties
    
    private var changesToSave: Bool {
        return model.name != usernameTextField.text ||
               model.about != aboutTextView.text ||
               model.picture != userPictureImageView.image
    }
    
    // MARK: - Initializers
    
    init(model: IAppUserModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stylizeWhenLoading()
        setDelegates()
        
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        model.load { [unowned self] profile in
            guard let profile = profile else {
                self.makeButtons(self.editButton, active: true)
                self.progressRing.stopAnimating()
                return
            }
            
            self.model.set(on: profile)
            
            if let name = profile.name {
                self.usernameTextField.text = name
            }
            
            if let about = profile.about {
                self.aboutTextView.text = about
            }
            
            if let picture = profile.picture {
                self.userPictureImageView.image = picture
            }
            
            self.makeButtons(self.editButton, active: true)
            self.progressRing.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.setKeyboardDelegate(self.view)
        model.turnKeyboard(on: true)
        
        configureNavigationPane()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        model.turnKeyboard(on: false)
        model.setKeyboardDelegate(nil)
    }
    
    // MARK: - IBActions
    
    @IBAction private func didEditButtonTap() {
        isEdit(on: true)
    }
    
    @IBAction private func didSaveButtonTap(_ sender: UIButton) {
        view.endEditing(true)
        progressRing.startAnimating()
        makeButtons(saveButton, active: false)
        
        if usernameTextField.text != model.name {
            model.name = usernameTextField.text
        }
        
        if aboutTextView.text != model.about {
            model.about = aboutTextView.text
        }
        
        if userPictureImageView.image != model.picture {
            model.picture = userPictureImageView.image
        }
        
        model.save() { [weak self] isError in
            if !isError {
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
            self?.isEdit(on: false)
        }
    }
    
    // MARK: - Avatar
    
    @IBAction private func choosePicture() {
        view.endEditing(true)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: { _ in
            self.model.makeAction(.photoLibrary, appeal: "галерее")
        }))
        actionSheet.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { _ in
            self.model.makeAction(.camera, appeal: "камере")
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - UI
    
    private func stylizeWhenLoading() {
        applyBlackButtonStyle(saveButton, editButton)
        progressRing.startAnimating()
        makeButtons(editButton, active: false)
    }
    
    private func applyBlackButtonStyle(_ buttons: UIButton...) {
        for button in buttons {
            button.layer.borderWidth = 2
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            button.layer.cornerRadius = 15
        }
    }
    
    private func makeButtons(_ buttons: UIButton..., active: Bool) {
        for button in buttons {
            button.alpha = active ? 1 : 0.5
            button.isUserInteractionEnabled = active
        }
    }
    
    private func isEdit(on: Bool) {
        saveButton.isHidden = !on
        editButton.isHidden = on
        
        cameraButton.isHidden = !on
        
        usernameTextField.isUserInteractionEnabled = on
        usernameTextField.layer.borderColor = on ? #colorLiteral(red: 0.7294117647, green: 0.7294117647, blue: 0.7294117647, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        aboutTextView.isEditable = on
        aboutTextView.layer.borderColor = on ? #colorLiteral(red: 0.7294117647, green: 0.7294117647, blue: 0.7294117647, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func configureNavigationPane() {
        navigationItem.title = "Профиль"

        let rightItem = UIBarButtonItem(title: "Закрыть",
                                        style: .plain,
                                        target: self,
                                        action: #selector(close))
        navigationItem.setRightBarButton(rightItem, animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    // MARK: - Others
    
    private func setDelegates() {
        aboutTextView.delegate = self
        usernameTextField.delegate = self
        model.setPermissionsDelegate(self)
    }
    
}

extension ProfileViewController: IPermissionsDelegate {
    
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
    
}

extension ProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        makeButtons(saveButton, active: changesToSave)
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        makeButtons(saveButton, active: changesToSave)
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
        makeButtons(saveButton, active: changesToSave)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
