// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NFTSendViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: NetworkFeePickerView!

    var presenter: NFTSendPresenter!

    private var viewModel: NFTSendViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension NFTSendViewController {

    func update(with viewModel: NFTSendViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        if collectionView.visibleCells.isEmpty { collectionView.reloadData() }
        else { updateCells() }
    }
    
    func presentNetworkFeePicker(networkFees: [NetworkFee]) {
        dismissKeyboard()
        let cell = collectionView.visibleCells.first { $0 is NFTSendCTACollectionViewCell } as! NFTSendCTACollectionViewCell
        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: networkFees,
            onFeeSelected: onFeeSelected(),
            at: .init(x: Theme.padding, y: fromFrame.midY)
        )
    }
    
    @objc func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension NFTSendViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel?.items[indexPath.section] else { fatalError() }
        if let input = item as? NFTSendViewModel.ItemNft {
            let cell = collectionView.dequeue(NFTSendImageCollectionViewCell.self, for: indexPath)
            cell.update(with: input.data)
            return cell
        }
        if let input = item as? NFTSendViewModel.ItemAddress {
            let cell = collectionView.dequeue(NFTSendToCollectionViewCell.self, for: indexPath)
            cell.update(with: input.data, handler: nftSendTokenHandler())
            return cell
        }
        if let input = item as? NFTSendViewModel.ItemSend {
            let cell = collectionView.dequeue(NFTSendCTACollectionViewCell.self, for: indexPath)
            cell.update(with: input, handler: nftSendCTAHandler())
            return cell
        }
        fatalError("Item not handled")
        
    }
}

extension NFTSendViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { dismissKeyboard() }
}

private extension NFTSendViewController {
    
    func configureUI() {
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: "chevron.left".assetImage,
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.setCollectionViewLayout(compositionalLayout(), animated: false)
        feesPickerView.isHidden = true
    }
    
    func onFeeSelected() -> ((NetworkFee) -> Void) {
        { [weak self] item in self?.onTapped(NFTSendPresenterEvent.NetworkFeeChanged(value: item))() }
    }
    
    @objc func navBarLeftActionTapped() {
        onTapped(NFTSendPresenterEvent.Dismiss())()
    }
}

private extension NFTSendViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(1)
            )
            let outerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item]
            )
            let sectionInset: CGFloat = Theme.padding
            let section = NSCollectionLayoutSection(group: outerGroup)
            section.contentInsets = .init(
                top: index == 0 ? sectionInset : 0,
                leading: sectionInset,
                bottom: sectionInset,
                trailing: sectionInset
            )
            return section
        }
    }
    
    func updateCells() {
        collectionView.visibleCells.forEach {
            switch $0 {
            case let addressCell as NFTSendToCollectionViewCell:
                guard let address = viewModel?.items.address else { return }
                addressCell.update(with: address, handler: nftSendTokenHandler())
            case let imageCell as NFTSendImageCollectionViewCell:
                guard let nftItem = viewModel?.items.nft else { return }
                imageCell.update(with: nftItem)
            case let ctaCell as NFTSendCTACollectionViewCell:
                guard let cta = viewModel?.items.send else { return }
                ctaCell.update(with: cta, handler: nftSendCTAHandler())
            default: fatalError()
            }
        }
    }
}

private extension NFTSendViewController {
    
    func nftSendTokenHandler() -> NetworkAddressPickerView.Handler {
        .init(
            onAddressChanged: onAddressChanged(),
            onQRCodeScanTapped: onTapped(NFTSendPresenterEvent.QrCodeScan()),
            onPasteTapped: onPasteFromKeyboard(),
            onSaveTapped: onTapped(NFTSendPresenterEvent.SaveAddress())
        )
    }
    
    func onPasteFromKeyboard() -> () -> Void {
        { [weak self] in
            self?.onTapped(
                NFTSendPresenterEvent.PasteAddress(value: UIPasteboard.general.string ?? "")
            )()
        }
    }

    func onAddressChanged() -> (String) -> Void {
        { [weak self] value in self?.onTapped(NFTSendPresenterEvent.AddressChanged(value: value))() }
    }
    
    func nftSendCTAHandler() -> NFTSendCTACollectionViewCell.Handler {
        .init(
            onNetworkFeesTapped: onTapped(NFTSendPresenterEvent.NetworkFeeTapped()),
            onCTATapped: onTapped(NFTSendPresenterEvent.Review())
        )
    }
    
    func onTapped(_ event: NFTSendPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event: event) }
    }
}

extension Array where Element == NFTSendViewModel.Item {
    var nft: NFTItem? {
        let item = first { $0 is NFTSendViewModel.ItemNft }
        return (item as? NFTSendViewModel.ItemNft)?.data
    }

    var address: NetworkAddressPickerViewModel? {
        let item = first { $0 is NFTSendViewModel.ItemAddress }
        return (item as? NFTSendViewModel.ItemAddress)?.data
    }

    var send: NFTSendViewModel.ItemSend? {
        let item = first { $0 is NFTSendViewModel.ItemSend }
        return item as? NFTSendViewModel.ItemSend
    }
}
