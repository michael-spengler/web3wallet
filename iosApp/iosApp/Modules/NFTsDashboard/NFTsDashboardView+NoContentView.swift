// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension NFTsDashboardViewController {
    
    func makeNoContentView() -> ScrollView {
        let scrollView = ScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.color.activityIndicator
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        let imageViewGroup = UIView()
        imageViewGroup.backgroundColor = .clear
        let imageView = UIImageView()
        imageView.image = "overscroll_ape".assetImage
        imageViewGroup.addSubview(imageView)
        imageView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 150)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 150))
            ]
        )
        let titleLabel = UILabel()
        titleLabel.apply(style: .title3)
        titleLabel.textAlignment = .center
        titleLabel.text = Localized("nfts.dashboard.noContent.title")
        let bodyLabel = UILabel()
        bodyLabel.apply(style: .body)
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        bodyLabel.text = Localized("nfts.dashboard.noContent.body")
        let ctaButton = Button()
        ctaButton.style = .primary
        ctaButton.setTitle(Localized("nfts.dashboard.noContent.cta"), for: .normal)
        ctaButton.addTarget(self, action: #selector(refreshNoContent), for: .touchUpInside)
        let stackView = VStackView(
            [
                imageViewGroup,
                titleLabel,
                bodyLabel,
                ctaButton
            ]
        )
        stackView.spacing = Theme.padding
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(stackView)
        stackView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.padding)
                )
            ]
        )
        scrollView.addSubview(view)
        view.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(
                        constant: Theme.padding
                    )
                ),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor)
            ]
        )
        return scrollView
    }
}
