package com.sonsofcrypto.web3walletcore.modules.account

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.formatters.Formatters.Style.Custom
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.viewModels.CandlesViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.loaded
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.account.AccountViewModel.Header.Button
import com.sonsofcrypto.web3walletcore.modules.account.AccountViewModel.Transaction.Empty
import com.sonsofcrypto.web3walletcore.modules.account.AccountViewModel.Transaction.Loading
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeDestination.More
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeDestination.Receive
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeDestination.Send
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeDestination.Swap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class AccountPresenterEvent {
    object Receive: AccountPresenterEvent()
    object Send: AccountPresenterEvent()
    object Swap: AccountPresenterEvent()
    object More: AccountPresenterEvent()
    object PullDownToRefresh: AccountPresenterEvent()
}

interface AccountPresenter {
    fun present()
    fun handle(event: AccountPresenterEvent)
}

class DefaultAccountPresenter(
    private var view: WeakRef<AccountView>,
    private var wireframe: AccountWireframe,
    private var interactor: AccountInteractor,
    private var context: AccountWireframeContext,
): AccountPresenter {
    private var fetchingTransactions = false
    private val bgScope = CoroutineScope(bgDispatcher)
    private val uiScope = CoroutineScope(uiDispatcher)

    override fun present() {
        updateView()
        refreshTransactions()
    }

    override fun handle(event: AccountPresenterEvent) {
        when(event) {
            is AccountPresenterEvent.Receive -> wireframe.navigate(Receive)
            is AccountPresenterEvent.Send -> wireframe.navigate(Send)
            is AccountPresenterEvent.Swap -> wireframe.navigate(Swap)
            is AccountPresenterEvent.More -> wireframe.navigate(More)
            is AccountPresenterEvent.PullDownToRefresh -> refreshTransactions()
        }
    }

    private fun updateView() = view.get()?.update(viewModel())

    private fun refreshTransactions() {
        fetchingTransactions = true
        updateView()
        bgScope.launch {
            interactor.fetchTransactions(context.network, context.currency)
            fetchingTransactions = false
            uiScope.launch { updateView() }
        }
    }

    private fun viewModel(): AccountViewModel = AccountViewModel(
        context.currency.name,
        headerViewModel(),
        addressViewModel(),
        candlesViewModel(),
        marketInfoViewModel(),
        bonusActionViewModel(),
        transactionsViewModel(),
    )

    private fun headerViewModel(): AccountViewModel.Header {
        val pct = interactor.market(context.currency)?.priceChangePercentage24h ?: 0.toDouble()
        return AccountViewModel.Header(
            Formatters.currency.format(
                interactor.cryptoBalance(context.network, context.currency),
                context.currency,
                Custom(15u)
            ),
            Formatters.fiat.format(
                BigDec.from(interactor.fiatBalance(context.network, context.currency)),
                Custom(20u),
                "usd"
            ),
            Formatters.pct.format(pct, true),
            pct >= 0,
            headerButtonsViewModel(),
        )
    }

    private fun headerButtonsViewModel(): List<Button> = listOf(
        Button(Localized("receive"), "account.receive.large"),
        Button(Localized("send"), "account.send.large"),
        Button(Localized("swap"), "account.swap.large"),
        Button(Localized("more"), "account.more.large"),
    )

    private fun addressViewModel(): AccountViewModel.Address = AccountViewModel.Address(
        Formatters.Companion.networkAddress.format(
            interactor.address(context.network), 12, context.network
        ),
        interactor.address(context.network),
        "square.on.square"
    )

    private fun candlesViewModel(): CandlesViewModel = CandlesViewModel.loaded(
            interactor.candles(context.currency) ?: emptyList()
        )

    private fun marketInfoViewModel(): AccountViewModel.MarketInfo = AccountViewModel.MarketInfo(
        Formatters.fiat.format(
            BigDec.from(interactor.market(context.currency)?.marketCap ?: 0.toDouble()),
            Custom(8u),
            "usd"
        ),
        Formatters.fiat.format(
            BigDec.from(interactor.market(context.currency)?.currentPrice ?: 0.toDouble()),
            Custom(8u),
            "usd"
        ),
        Formatters.fiat.format(
            BigDec.from(interactor.market(context.currency)?.totalVolume ?: 0.toDouble()),
            Custom(8u),
            "usd"
        )
    )

    private fun bonusActionViewModel(): AccountViewModel.BonusAction? {
        if (context.currency != Currency.cult()) return null
        return AccountViewModel.BonusAction(Localized("account.action.bonus.cult"))
    }

    private fun transactionsViewModel(): List<AccountViewModel.Transaction> {
        val transactions = interactor.transactions(context.network, context.currency).map {
            transactionViewModel(it)
        }.toMutableList()
        if (transactions.isEmpty() && !fetchingTransactions) {
            return listOf(Empty(Localized("account.marketInfo.transactions.empty")))
        } else if (fetchingTransactions) {
            transactions.add(0, Loading(Localized("account.marketInfo.transactions.loading")))
        }
        return transactions
    }

    private fun transactionViewModel(
        t: AccountTransaction
    ): AccountViewModel.Transaction {
        val date = t.date?.let { Formatters.date.format(it, "dd/MM/yyyy") } ?: t.blockNumber
        val isReceive = t.to == interactor.address(context.network)
        val fiatPrice = BigDec.from(interactor.fiatPrice(t.amount, context.currency))
        val address = if (isReceive) t.from else t.to
        val data = AccountViewModel.Transaction.Data(
            date,
            Formatters.networkAddress.format(address, 10, context.network),
            Formatters.currency.format(t.amount, context.currency, Custom(20u)),
            Formatters.fiat.format(fiatPrice, Custom(12u), "usd"),
            isReceive,
            t.txHash
        )
        return AccountViewModel.Transaction.Loaded(data)
    }
}
