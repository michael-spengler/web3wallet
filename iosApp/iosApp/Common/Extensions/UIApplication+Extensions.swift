// Created by web3dgn on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UIApplication {
    
    var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .keyWindow
    }
    
    var rootVc: UIViewController? {
        keyWindow?.rootViewController
    }
}
