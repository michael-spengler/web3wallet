package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3walletcore.common.viewModels.SectionFooterViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SegmentWithTextAndSwitchCellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SwitchCollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SwitchTextInputCollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.TextInputCollectionViewModel

data class MnemonicUpdateViewModel(
    val sections : List<Section>,
    val cta: String
) {
    data class Section(
        val items: List<Item>,
        val footer: SectionFooterViewModel?,
    ) {
        sealed class Item {
            data class Mnemonic(val mnemonic: String): Item()
            data class TextInput(
                val viewModel: TextInputCollectionViewModel
            ): Item()
            data class Switch(
                val viewModel: SwitchCollectionViewModel
            ): Item()
            data class SwitchWithTextInput(
                val viewModel: SwitchTextInputCollectionViewModel
            ): Item()
            data class SegmentWithTextAndSwitchInput(
                val viewModel: SegmentWithTextAndSwitchCellViewModel
            ): Item()
            data class Delete(val title: String): Item()
        }
    }
}
