// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AccountChartCell: CollectionViewCell {
    @IBOutlet weak var candlesView: CandlesView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Theme.cornerRadiusSmall * 2
    }
    
    override func setSelected(_ selected: Bool) {}
}

extension AccountChartCell {

    func update(with viewModel: CandlesViewModel?) {
        guard let viewModel = viewModel else { return }
        candlesView.update(viewModel)
    }
}
