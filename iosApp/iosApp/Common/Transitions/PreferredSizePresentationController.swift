// Created by web3d3v on 12/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// TODO: @Annon: why `modalDismissDelegate` is needed, conforming to `ModalDismissDelegate` should be ok 🤔
/// ModalDismissProtocol implement to support handeling of dismissal via tap on
/// backgound chrome. Normally should be implemend by `presentedViewController`.
@objc protocol ModalDismissProtocol: AnyObject {
    weak var modalDismissDelegate: ModalDismissDelegate? { get set }
}

/// `ModalDismissDelegate` called by `ModalDismissProtocol`. Should be
/// implemented by `presentingViewController`.
@objc protocol ModalDismissDelegate: AnyObject {
    func viewControllerDismissActionPressed(_ viewController: UIViewController?)
}

/// PreferredSizePresentationController sizes `presentedViewController` by its
/// `preferredContentSize` and centers it in `presentingViewController`. If
/// `preferredContentSize` is not available or zero, size is computer using
/// `systemLayoutSizeFitting`. Stuble motion effect are added to
/// `presentedViewController`
class PreferredSizePresentationController: UIPresentationController {

    private weak var bgView: UIView?

    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            var size = CGSize.zero
            let bounds = containerViewBounds()
            // If preferred size is explicitly set use it
            if presentedViewController.preferredContentSize != .zero {
                size = presentedViewController.preferredContentSize
            // Compute size from presented view
            } else {
                let width = max(
                    min(bounds.width, bounds.height) * Constant.widthScaler,
                    Constant.minWidth
                )

                let presentedView = presentedViewController.view

                size = presentedView?.systemLayoutSizeFitting(
                    CGSize(width: width - 2 * Constant.margin, height: 0),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .defaultLow
                ) ?? size
            }

            size.width = max(Constant.minWidth, size.width)
            size.height = max(Constant.minWidth, size.height)

            return .init(
                origin: .init(
                    x: (bounds.width - size.width) / 2,
                    // NOTE: bounds.height - keyboard.height so the view is centered above the keyboard
                    y: ((bounds.height - 216) - size.height) / 1.5
                ),
                size: size
            )
        }
    }

    override func presentationTransitionWillBegin() {
        
        super.presentationTransitionWillBegin()
        
        // Animate background
        let bgView = newBGView()
        containerView?.addSubview(bgView)
        self.bgView = bgView
        presentedView?.layer.cornerRadius = Constant.cornerRadius

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = Constant.bgAlpha
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        
        guard completed == true else { return }
        
        // Add motion effects
        let offset = 12
        [
            motionEffect(Constant.vmPath, type: .tiltAlongVerticalAxis),
            motionEffect(Constant.hmPath, type: .tiltAlongHorizontalAxis)
        ].forEach {
            $0.minimumRelativeValue = -offset
            $0.maximumRelativeValue = offset
            presentedView?.addMotionEffect($0)
        }
    }

    override func dismissalTransitionWillBegin() {
        
        super.dismissalTransitionWillBegin()

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        super.dismissalTransitionDidEnd(completed)

        guard !completed else {
            bgView?.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: Constant.animDuration) {
            self.bgView?.alpha = Constant.bgAlpha
        }
    }

    override func containerViewWillLayoutSubviews() {
        
        super.containerViewWillLayoutSubviews()
        
        bgView?.frame = containerView?.bounds ?? .zero
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    override func adaptivePresentationStyle(
        for traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        
        .custom
    }
}

private extension PreferredSizePresentationController {
    
    func motionEffect(
        _ keyPath: String,
        type: UIInterpolatingMotionEffect.EffectType
    ) -> UIInterpolatingMotionEffect {
        
        UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
    }

    func newBGView() -> UIView {
        
        let bgView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        bgView.frame = containerViewBounds()
//        let bgView = UIView(frame: containerViewBounds())
//        bgView.backgroundColor = UIColor.black.withAlphaComponent(Const.bgAlpha)
        bgView.alpha = 0
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapAction(_:))
        )
        bgView.contentView.addGestureRecognizer(tap)
//        bgView.addGestureRecognizer(tap)
        return bgView
    }
    
    @objc func tapAction(_ recognizer: UITapGestureRecognizer) {
        
        if let vc = presentingViewController as? ModalDismissProtocol {
            vc.modalDismissDelegate?.viewControllerDismissActionPressed(presentedViewController)
        } else if let vc = presentedViewController as? ModalDismissDelegate {
            vc.viewControllerDismissActionPressed(presentedViewController)
        } else if let vc = presentedViewController as? UINavigationController,
                  let childVc = vc.topViewController as? ModalDismissDelegate {
            childVc.viewControllerDismissActionPressed(presentedViewController)
        } else {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    func containerViewBounds() -> CGRect {
        
        containerView?.bounds ?? presentingViewController.view.bounds
    }

    private struct Constant {
        
        static let widthScaler: CGFloat = 0.91
        static let minWidth: CGFloat = 320
        static let margin: CGFloat = 16
        static let bgAlpha: CGFloat = 1.0
        static let hmPath = "transform.translation.x"
        static let vmPath = "transform.translation.y"
        static let cornerRadius: CGFloat = 16
        static let animDuration: TimeInterval = 0.2
    }
}
