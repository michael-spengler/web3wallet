// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class Button: UIButton {
    
    var style: Style = .primary {
        didSet { configure() }
    }
    
    override var isEnabled: Bool {
        didSet {
            //alpha = isEnabled ? 1 : 0.75
            updateBackgroundColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configure()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        switch style {
        case .primary:
            size.height = Theme.buttonHeight
        case .secondary:
            size.height = Theme.buttonHeight
        case .secondarySmall:
            size.height = Theme.buttonHeightExtraSmall
        case .dashboardAction:
            size.height = Theme.buttonSmallHeight
        case .accountAction:
            break
        }
        return size
    }
}

extension Button {
    
    enum Style {
        case primary(action: PrimaryAction)
        case secondary
        case secondarySmall(leftImage: UIImage?)
        case dashboardAction(leftImage: UIImage?)
        case accountAction
        
        enum PrimaryAction {
            case `default`
            case destructive
        }
        
        static var primary: Self {
            .primary(action: .`default`)
        }
    }
}

private extension Button {
    
    func configure() {
        switch style {
        case .primary:
            var configuration = UIButton.Configuration.plain()
            configuration.titleTextAttributesTransformer = .init{ incoming in
                var outgoing = incoming
                outgoing.font = Theme.font.title3
                return outgoing
            }
            configuration.titlePadding = Theme.padding * 0.5
            configuration.imagePadding = Theme.padding * 0.5
            self.configuration = configuration
            updateConfiguration()
            updateBackgroundColor()
            tintColor = Theme.color.buttonTextPrimary
            layer.cornerRadius = Theme.cornerRadiusSmall
            setTitleColor(Theme.color.buttonTextPrimary, for: .normal)
            setTitleColor(Theme.color.buttonTextPrimary.withAlpha(0.5), for: .disabled)
        case .secondary:
            var configuration = UIButton.Configuration.plain()
            configuration.titleTextAttributesTransformer = .init{ incoming in
                var outgoing = incoming
                outgoing.font = Theme.font.title3
                return outgoing
            }
            configuration.titlePadding = Theme.padding * 0.5
            configuration.imagePadding = Theme.padding * 0.5
            self.configuration = configuration
            updateConfiguration()
            updateBackgroundColor()
            tintColor = Theme.color.buttonTextSecondary
            layer.cornerRadius = Theme.cornerRadiusSmall
            layer.borderWidth = 1
            layer.borderColor = Theme.color.buttonTextSecondary.cgColor
            setTitleColor(Theme.color.buttonTextSecondary, for: .normal)
        case let .secondarySmall(leftImage):
            updateSecondaryStyle(leftImage: leftImage)
            layer.cornerRadius = Theme.buttonHeightExtraSmall.half
        case let .dashboardAction(leftImage):
            updateSecondaryStyle(leftImage: leftImage)
            layer.cornerRadius = Theme.buttonSmallHeight.half
        case .accountAction:
            updateBackgroundColor()
            tintColor = Theme.color.textPrimary
            imageView?.tintColor = Theme.color.textPrimary
        }
        invalidateIntrinsicContentSize()
    }
    
    func updateBackgroundColor() {
        switch style {
        case let .primary(action):
            switch action {
            case .`default`:
                backgroundColor = Theme.color.buttonBgPrimary.withAlpha(
                    isEnabled ? 1.0 : 0.5
                )
            case .destructive:
                backgroundColor = Theme.color.destructive.withAlpha(
                    isEnabled ? 1.0 : 0.5
                )
            }
        case .secondary, .secondarySmall, .dashboardAction:
            backgroundColor = .clear
        case .accountAction:
            backgroundColor = Theme.color.bgPrimary
        }
    }
    
    func updateSecondaryStyle(leftImage: UIImage?) {
        
        var configuration = UIButton.Configuration.plain()
        configuration.titleTextAttributesTransformer = .init{ incoming in
            var outgoing = incoming
            outgoing.font = Theme.font.footnote
            return outgoing
        }
        configuration.titlePadding = Theme.padding * 0.5
        configuration.imagePadding = Theme.padding * 0.5
        self.configuration = configuration
        updateConfiguration()
        updateBackgroundColor()
        tintColor = Theme.color.buttonTextSecondary
        layer.borderWidth = 0.5
        layer.borderColor = Theme.color.buttonTextSecondary.cgColor
        setTitleColor(Theme.color.buttonTextSecondary, for: .normal)
        titleLabel?.textAlignment = .natural
        
        if let leftImage = leftImage {
            setImage(
                leftImage.withRenderingMode(.alwaysTemplate)
                    .withTintColor(Theme.color.buttonTextSecondary),
                for: .normal
            )
        }
        
    }
}

final class VerticalButton: Button {
    
    override var style: Button.Style {
        didSet { super.style = style }
    }

    override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize.sizeWithHeight(52)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style = .accountAction
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let imageView = self.imageView, let label = self.titleLabel else {
            return
        }
        
        imageView.center.x = bounds.width / 2
        imageView.center.y = bounds.height * 0.3333
        imageView.contentMode = .center

        // TODO: Remove this hack. Introduced coz color and font were on being
        // set when setting from `AccountHeaderCell`
        label.apply(style: .footnote)
        label.textAlignment = .center

        label.bounds.size.width = bounds.width
        label.bounds.size.height = bounds.height * 0.3333
        label.center.x = bounds.width / 2
        label.center.y = bounds.height - label.bounds.height / 2 - 4
    }
}

final class CustomVerticalButton: UIView {
    
    struct ViewModel {
        
        let title: String
        let imageName: String
        let onTap: () -> Void
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint?
    
    private var onTap: (() -> Void)?
    
    override func awakeFromNib() {

        super.awakeFromNib()
        
        backgroundColor = Theme.color.bgPrimary
        layer.cornerRadius = Theme.cornerRadiusSmall
        tintColor = Theme.color.textPrimary
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.color.textPrimary
        self.iconImageView = imageView
        wrapperView.addSubview(imageView)
        imageView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        let nameLabel = UILabel()
        nameLabel.apply(style: .subheadline)
        nameLabel.textAlignment = .center
        self.nameLabel = nameLabel
        
        let vStack = VStackView([wrapperView, nameLabel])
        vStack.spacing = Theme.padding.half
        addSubview(vStack)
        
        vStack.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        guard gestureRecognizers?.isEmpty ?? true else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func update(
        with viewModel: ViewModel
    ) {
        
        nameLabel.text = viewModel.title
        iconImageView.image = viewModel.imageName.assetImage
        ?? viewModel.imageName.assetImage
        
        self.onTap = viewModel.onTap
    }
}

private extension CustomVerticalButton {
    
    @objc func viewTapped() {
        
        onTap?()
    }
}
