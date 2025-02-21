// Created by web3d4v on 01/12/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class SettingsServiceActionTriggerAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> SettingsServiceActionTrigger in
            DefaultSettingsServiceActionTrigger(
                keyStoreService: resolver.resolve()
            )
        }
    }
}
