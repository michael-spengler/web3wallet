// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworkPickerView: AnyObject {
    func update(with viewModel: NetworkPickerViewModel)
}

final class NetworkPickerViewController: BaseViewController {
    
    enum CollectionTag: Int {
        case filters = 1
        case items = 2
    }

    var presenter: NetworkPickerPresenter!

    private var viewModel: NetworkPickerViewModel?
    
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var searchTextFieldBox: UIView!
    @IBOutlet weak var searchTextField: TextField!
    @IBOutlet weak var clearSearchButton: UIButton!
    
    private var searchTerm = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension NetworkPickerViewController {
    
    @IBAction func clearSearchInputText() {
        searchTextField.text = ""
        presenter.handle(.search(searchTerm: ""))
    }
}

extension NetworkPickerViewController: NetworkPickerView {

    func update(with viewModel: NetworkPickerViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        clearSearchButton.isHidden = searchTextField.text?.isEmpty ?? true
        itemsCollectionView.reloadData()
    }
}

private extension NetworkPickerViewController {
        
    func configureUI() {
        searchTextFieldBox.backgroundColor = Theme.color.bgPrimary
        searchTextFieldBox.layer.cornerRadius = 16
        searchTextField.text = nil
        searchTextField.delegate = self
        clearSearchButton.isHidden = true
    }
}

extension NetworkPickerViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionViewCell(at: indexPath, for: collectionView)
    }
}

extension NetworkPickerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        itemSelectedAt(indexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

extension NetworkPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.frame.width, height: 56)
    }
}

extension NetworkPickerViewController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.handle(.search(searchTerm: textField.text ?? ""))
    }
}

private extension NetworkPickerViewController {
        
    func itemSelectedAt(indexPath: IndexPath) {
        guard let network = viewModel?.items[indexPath.item] else { return }
        presenter.handle(.selectItem(network))
    }
    
    func collectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        itemCollectionViewCell(at: indexPath, for: collectionView)
    }
    
    func itemCollectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let network = viewModel?.items[indexPath.item] else {
            fatalError()
        }
        let cell = collectionView.dequeue(
            NetworkPickerItemCell.self,
            for: indexPath
        )
        cell.update(
            with: network,
            and: collectionView.frame.size.width
        )
        return cell
    }
    
    @objc func dismissKeyboard() {
        searchTextField.resignFirstResponder()
    }
}
