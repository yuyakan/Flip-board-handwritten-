//
//  AdView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2022/05/17.
//

import SwiftUI
import GoogleMobileAds

typealias AdView = BannerView

struct BannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BannerViewController {
        BannerViewController()
    }

    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {}
}

final class BannerViewController: UIViewController {
    private var bannerView: GADBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBanner()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.loadBanner()
        }
    }

    private func loadBanner() {
        let frame = view.frame.isEmpty ? UIScreen.main.bounds : view.frame
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)

        if bannerView == nil {
            let banner = GADBannerView(adSize: adSize)
            banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト
            banner.rootViewController = self
            banner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(banner)
            NSLayoutConstraint.activate([
                banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            bannerView = banner
        } else {
            bannerView?.adSize = adSize
        }
        bannerView?.load(GADRequest())
    }
}
