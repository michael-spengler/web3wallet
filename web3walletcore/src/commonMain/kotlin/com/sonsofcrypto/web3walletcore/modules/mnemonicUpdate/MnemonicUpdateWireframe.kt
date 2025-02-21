package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext

data class MnemonicUpdateWireframeContext(
    val keyStoreItem: KeyStoreItem,
    val onUpdateHandler: ((KeyStoreItem) -> Unit),
    val onDeleteHandler: (() -> Unit),
)

sealed class MnemonicUpdateWireframeDestination {
    data class Authenticate(
        val context: AuthenticateWireframeContext
    ): MnemonicUpdateWireframeDestination()
    data class Alert(val context: AlertWireframeContext): MnemonicUpdateWireframeDestination()
    object Dismiss: MnemonicUpdateWireframeDestination()
}

interface MnemonicUpdateWireframe {
    fun present()
    fun navigate(destination: MnemonicUpdateWireframeDestination)
}