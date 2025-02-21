package com.sonsofcrypto.web3lib.utils

import CoreCrypto.CoreCryptoAESCTRXOREmptyOnError
import CoreCrypto.CoreCryptoCurveSecp256k1
import CoreCrypto.CoreCryptoSecureRandFatal
import CoreCrypto.CoreCryptoSignEmptyOnError

/** Cryptographically secure source of randomnes */
@Throws(Exception::class)
actual fun secureRand(size: Int): ByteArray {
    return CoreCryptoSecureRandFatal(size.toLong())!!.toByteArray()
}
@Throws(Exception::class)
actual fun aesCTRXOR(key: ByteArray, inText: ByteArray, iv: ByteArray): ByteArray {
    val result: ByteArray = CoreCryptoAESCTRXOREmptyOnError(
        key.toDataFull(),
        inText.toDataFull(),
        iv.toDataFull()
    )!!.toByteArray()
    if (result.isEmpty()) {
        throw Exception("aesCTRXOR failed")
    }
    return result
}

@Throws(Exception::class)
actual fun sign(digest: ByteArray, key: ByteArray): ByteArray {
    val sig = CoreCryptoSignEmptyOnError(
        digest.toDataFull(),
        key.toDataFull(),
        curveInt(Curve.SECP256K1)
    )!!.toByteArray()
    if (sig.isEmpty()) {
        throw Exception("Failed to sign data")
    }
    return sig
}

private fun curveInt(curve: Curve): Long {
    return when (curve) {
        Curve.SECP256K1 -> CoreCryptoCurveSecp256k1
    }
}