// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension NFTsCollectionViewController {
    
    func makeMainScrollView() -> UIScrollView {
        let mainScrollView = ScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.color.activityIndicator
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        let scrollableContentView = UIView()
        mainScrollView.addSubview(scrollableContentView)
        self.scrollableContentView = scrollableContentView
        scrollableContentView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.padding)
                ),
                .layout(
                    anchor: .bottomAnchor,
                    constant: .equalTo(constant: Theme.padding)
                ),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor)
            ]
        )        
        return mainScrollView
    }
}
