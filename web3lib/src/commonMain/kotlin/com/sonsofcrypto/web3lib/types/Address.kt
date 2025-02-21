package com.sonsofcrypto.web3lib.types

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonPrimitive

typealias AddressBytes = ByteArray
typealias AddressHexString = String

/** Address */
@Serializable
sealed class Address() {
    @Serializable
    data class Bytes(val data: AddressBytes) : Address()
    @Serializable
    data class HexString(val hexString: AddressHexString) : Address()
    @Serializable
    data class Name(val name: String) : Address()

    companion object {
        fun fromHexString(hexString: String?): Address.HexString? {
            return if (hexString != null && hexString != "null") {
                HexString(hexString)
            } else null
        }
    }
}

fun Address.toHexStringAddress(): Address.HexString = when (this) {
    is Address.HexString -> this
    is Address.Bytes -> Address.HexString(DataHexString(this.data))
    else -> TODO("Resolve name address")
}

fun Address.toHexString(): AddressHexString = this.toHexStringAddress().hexString


fun Address.jsonPrimitive(): JsonPrimitive = when (this) {
    is Address.HexString -> JsonPrimitive(hexString)
    is Address.Bytes -> JsonPrimitive(DataHexString(data))
    else -> JsonPrimitive("")
}


