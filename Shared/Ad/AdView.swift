//
//  AdView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2022/05/17.
//

import SwiftUI
import GoogleMobileAds

// 広告の一括制御フラグ。
// スクリーンショット撮影などで広告を隠したいときは true にする。
// リリース時は必ず false に戻すこと。
enum AdConfig {
    static let isHidden = false
}

typealias AdView = BannerAdView

struct BannerAdView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BannerAdViewController {
        BannerAdViewController()
    }

    func updateUIViewController(_ uiViewController: BannerAdViewController, context: Context) {}
}

final class BannerAdViewController: UIViewController {
    private var bannerView: BannerView?

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
        let adSize = largeAnchoredAdaptiveBanner(width: frame.width)

        if bannerView == nil {
            let banner = BannerView(adSize: adSize)
            // banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト
            banner.adUnitID = "ca-app-pub-3155724310732667/8877317702" // 本番
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
        bannerView?.load(Request())
    }
}
