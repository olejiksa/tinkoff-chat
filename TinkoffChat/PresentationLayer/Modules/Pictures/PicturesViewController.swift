//
//  PicturesViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol ICollectionPickerController: class {
    func close()
}

protocol IPicturesViewControllerDelegate: class {
    func collectionPickerController(_ picker: ICollectionPickerController, didFinishPickingImage image: UIImage)
}

class PicturesViewController: UIViewController {
    
    private let edgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    private let itemsPerRow: CGFloat = 3
    
    // MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    // MARK: - Dependencies
    
    private let model: IPicturesModel
    weak var collectionPickerDelegate: IPicturesViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(model: IPicturesModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureCollectionView()
        configureNavigationPane()
    }
    
    // MARK: - Utils
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: "PictureCell", bundle: nil), forCellWithReuseIdentifier: "PictureCell")
        collectionView.dataSource = self
        collectionView.delegate = self as UICollectionViewDelegate
    }
    
    private func configureData() {
        spinner.startAnimating()
        
        model.fetchAllPictures() { [weak self] pictures, error in
            if let pictures = pictures {
                self?.model.data = pictures
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.collectionView.reloadData()
                }
            } else {
                self?.spinner.stopAnimating()
                self?.showErrorMessage()
            }
        }
    }
    
    private func configureNavigationPane() {
        navigationItem.title = "Желтые цветы"
        
        let rightItem = UIBarButtonItem(title: "Закрыть",
                                        style: .plain,
                                        target: self,
                                        action: #selector(close))
        navigationItem.setRightBarButton(rightItem, animated: true)
    }
    
    private func showErrorMessage(askCheck: Bool = false) {
        DispatchQueue.main.async {
            var message = "Не удается загрузить изображение."
            if askCheck {
                message += " Проверьте доступ к сети."
            }
            
            let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ОК", style: .cancel))
            self.present(alertController, animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension PicturesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PictureCell
        let identifier = "\(PictureCell.self)"
        
        if let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? PictureCell {
            cell = dequeuedCell
        } else {
            cell = PictureCell(frame: CGRect.zero)
        }
        
        let picture = model.data[indexPath.item]
        DispatchQueue.global(qos: .userInteractive).async {
            self.model.fetchPicture(urlString: picture.previewUrl) { image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.setup(image: image, picture: picture)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PictureCell {
            DispatchQueue.global(qos: .userInteractive).async {
                guard let url = cell.largeImageUrl else {
                    self.showErrorMessage()
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.alpha = 0.1
                    self.spinner.startAnimating()
                }
                
                self.model.fetchPicture(urlString: url) { image in
                    DispatchQueue.main.async {
                        self.collectionView.alpha = 1
                        self.spinner.stopAnimating()
                        
                        guard let image = image else {
                            self.showErrorMessage(askCheck: true)
                            return
                        }
                        
                        self.collectionPickerDelegate?.collectionPickerController(self, didFinishPickingImage: image)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PicturesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect = UIScreen.main.bounds
        let oneMore = itemsPerRow + 1
        let width = screenRect.size.width - edgeInsets.left * oneMore
        let height = width / itemsPerRow
        
        return CGSize(width: floor(height), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return edgeInsets.left
    }
    
}

// MARK: - ICollectionPickerController

extension PicturesViewController: ICollectionPickerController {
    
    @objc func close() {
        dismiss(animated: true)
    }
    
}
