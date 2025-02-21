// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

extension NFTDetailViewController {
    
    func makeNFTImage(with item: NFTItem) -> UIView {
        var views = [UIView]()
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setImage(
            url: item.gatewayImageUrl,
            fallBackUrl: item.previewImageUrl,
            fallBackText: item.fallbackText
        )
        views.append(imageView)
        imageView.addConstraints(
            [
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(constant: nftImageSize.height)
                ),
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(constant: nftImageSize.width)
                )
            ]
        )
        let idLabel = UILabel()
        idLabel.apply(style: .body)
        idLabel.textAlignment = .center
        idLabel.text = Localized("nft.detail.section.id", item.identifier)
        views.append(idLabel)
        views.append(.vSpace(height: Theme.padding.half * 0.75))
        let containerView = UIView()
        let vStackView = VStackView(views)
        vStackView.spacing = Theme.padding.half
        vStackView.clipsToBounds = true
        containerView.addSubview(vStackView)
        vStackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
        vStackView.backgroundColor = Theme.color.bgPrimary
        vStackView.layer.cornerRadius = Theme.cornerRadius
        return containerView
    }
}

private extension NFTDetailViewController {
    
    func makeHeaderImage(with item: NFTItem) -> UIView {
        let label = UILabel(with: .headline)
        label.text = item.name
        label.textAlignment = .center
        return label
    }
    
    var nftImageSize: CGSize {
        let width: CGFloat
        if let view = navigationController?.view {
            width = view.frame.size.width - Theme.padding * 2
        } else {
            width = 220
        }
        return .init(
            width: width * 0.7,
            height: width * 0.7
        )
    }
}
