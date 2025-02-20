package com.sonsofcrypto.web3lib.services.coinGecko.model

import kotlinx.serialization.Serializable

@Serializable
data class Coin(
    val id: String,
    val symbol: String,
    val name: String,
    val platforms: Platforms?
) {

    @Serializable
    data class Platforms(
        val ethereum: String?
    )
}
