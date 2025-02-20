package com.sonsofcrypto.web3lib.provider

import com.sonsofcrypto.web3lib.types.Network
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.charsets.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

class ProviderLocal: ProviderJsonRpc {

    constructor(
        network: Network,
        dispatcher: CoroutineDispatcher = Dispatchers.Default,
        nameService: NameServiceProvider? = null
    ) : super(
        network = network,
        client = HttpClient() {
            Logging { level = LogLevel.NONE; logger = Logger.SIMPLE }
            install(ContentNegotiation) {
                json(
                    providerJson,
                    ContentType.Application.Json.withCharset(Charsets.UTF_8)
                )
            }
            install(HttpTimeout) {
                requestTimeoutMillis = 30000
                socketTimeoutMillis = 30000
            }
        },
        dispatcher = dispatcher,
        nameService = nameService,
    )

    /** Utilities */

    @Throws(Throwable::class)
    override fun url(): String = when (network.chainId) {
        1u -> "https://127.0.0.1:62302"
        else -> throw  Error.UnsupportedNetwork(network)
    }
}
