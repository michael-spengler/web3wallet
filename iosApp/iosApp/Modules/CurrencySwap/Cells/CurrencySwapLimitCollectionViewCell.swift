// Created by web3d4v on 18/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class CurrencySwapLimitCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let imageView = UIImageView(
            image: "coming-soon-meme".assetImage!.withRenderingMode(
                .alwaysTemplate
            ).withTintColor(
                Theme.color.textPrimary
            )
        )
        imageView.tintColor = Theme.color.textPrimary
        addSubview(imageView)
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.addSubview(imageView)
        imageView.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 112)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 112)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
        let titleLabel = UILabel()
        titleLabel.apply(style: .largeTitle)
        titleLabel.textAlignment = .center
        titleLabel.text = Localized("comingSoon").uppercased()
        let vStack = VStackView([wrapperView, titleLabel])
        vStack.spacing = Theme.padding
        addSubview(vStack)
        vStack.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .topAnchor, constant: .equalTo(constant: Theme.padding * 2))
            ]
        )
    }
}
