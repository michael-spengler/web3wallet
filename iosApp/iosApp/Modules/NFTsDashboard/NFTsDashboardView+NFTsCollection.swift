// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension NFTsDashboardViewController {
    
    typealias NFTCollectionItem = (
        index: Int,
        collection: NFTsDashboardViewModel.Collection
    )
    
    func makeNFTCollectionsContent() -> UIStackView {
        let collections = viewModel?.collectionItems ?? []
        guard !collections.isEmpty else {
            // NOTE: No content will be handled in the future, for now the data is mocked
            // and will always return a few collections
            return HStackView([])
        }
        var rows: [UIView] = []
        let titleLabel = UILabel(with: .title3)
        titleLabel.numberOfLines = 1
        titleLabel.text = Localized("nfts.dashboard.collection.title")
        //titleLabel.textColor = Theme.colour.systemRed
        titleLabel.textAlignment = .center
        rows.append(titleLabel)
        var index = 0
        while true {
            var item1: NFTCollectionItem?
            var item2: NFTCollectionItem?
            if index < collections.count {
                item1 = (index: index, collection: collections[index])
                index += 1
            }
            if index < collections.count {
                item2 = (index: index, collection: collections[index])
                index += 1
            }
            guard let item1 = item1 else { break }
            rows.append(
                makeNFTsCollectionRow(
                    with: item1,
                    and: item2
                )
            )
        }
        return VStackView(rows, spacing: Theme.padding)
    }
    
    func refreshNFTsCollections() {
        collectionsView?.removeAllSubview()
        let content = makeNFTCollectionsContent()
        collectionsView?.addSubview(content)
        content.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.padding))
            ]
        )
    }
}

private extension NFTsDashboardViewController {
    
    func makeNFTsCollectionRow(
        with item1: NFTCollectionItem,
        and item2: NFTCollectionItem?
    ) -> UIView {
        var views = [UIView]()
        views.append(makePopularNFTCollectionContent(with: item1))
        if let item2 = item2 {
            views.append(makePopularNFTCollectionContent(with: item2))
        } else {
            views.append(UIView())
        }
        return HStackView(views, spacing: Theme.padding)
    }
    
    func makePopularNFTCollectionContent(
        with item: NFTCollectionItem
    ) -> UIView {
        let view = UIView()
        let stackView = makeVerticalStack(with: item.collection)
        view.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor)
            ]
        )
        view.addConstraints(
            [
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: collectionItemSize.width)
                ),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: collectionItemSize.height)
                )
            ]
        )
        view.layer.cornerRadius = Theme.cornerRadius
        view.backgroundColor = Theme.color.bgPrimary
        view.clipsToBounds = true
        view.tag = item.index
        view.add(
            .targetAction(
                .init(target: self, selector: #selector(collectionItemSelected(_:)))
            )
        )
        return view
    }
    
    @objc func collectionItemSelected(_ tapGesture: UITapGestureRecognizer) {
        guard let tag = tapGesture.view?.tag else { return }
        guard let viewModel = viewModel else { return }
        guard viewModel.collectionItems.count > tag else { return }
        presenter.handle(event: NFTsDashboardPresenterEvent.ViewCollectionNFTs(idx: Int32(tag)))
    }
    
    func makeVerticalStack(
        with collection: NFTsDashboardViewModel.Collection
    ) -> UIView {
        let view = VStackView()
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        if let coverImage = collection.coverImage {
            imageView.setImage(url: coverImage)
        }
        view.addArrangedSubview(imageView)
        imageView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: collectionItemSize.width * 0.7)
                )
            ]
        )
        
        let font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
        let titleLabel = UILabel(with: .caption1)
        titleLabel.numberOfLines = 1
        titleLabel.text = collection.title
        titleLabel.textColor = Theme.color.textPrimary
        titleLabel.textAlignment = .center
        view.addArrangedSubview(titleLabel)
//        let authorLabel = UILabel()
//        authorLabel.numberOfLines = 1
//        authorLabel.attributedText = Localized(
//            "nfts.dashboard.collection.popular.author",
//            collection.author ?? ""
//        ).attributtedString(
//            with: font,
//            and: Theme.color.textPrimary,
//            updating: [collection.author ?? ""],
//            withColour: Theme.color.textPrimary,
//            andFont: font
//        )
//        authorLabel.textAlignment = .center
//        view.addArrangedSubview(authorLabel)
        view.spacing = Theme.padding * 0.5
        return view
    }
}

private extension NFTsDashboardViewModel {
    var collectionItems: [NFTsDashboardViewModel.Collection] {
        guard let input = self as? NFTsDashboardViewModel.Loaded else { return [] }
        return input.collections
    }
}
