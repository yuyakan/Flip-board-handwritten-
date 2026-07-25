//
//  InterstitialAd.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2023/11/19.
//

import GoogleMobileAds
import StoreKit
import SwiftUI

class Interstitial: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false

    private var interstitialAd: InterstitialAd?
    private var onDismiss: (() -> Void)?
    private var presentCount: Int = 0

    override init() {
        super.init()
    }

    // インタースティシャル広告の読み込み
    func loadInterstitial() {
        Task { @MainActor in
            await load()
        }
    }

    @MainActor
    private func load() async {
        let id = "ca-app-pub-3940256099942544/4411468910" // テスト
        // let id = "ca-app-pub-3155724310732667/8334696722" // 本番
        do {
            let ad = try await InterstitialAd.load(with: id, request: Request())
            ad.fullScreenContentDelegate = self
            interstitialAd = ad
            interstitialAdLoaded = true
            print("😍: 読み込みに成功しました")
        } catch {
            interstitialAd = nil
            interstitialAdLoaded = false
            print("😭: 読み込みに失敗しました: \(error.localizedDescription)")
        }
    }

    // インタースティシャル広告の表示（広告閉鎖後に onDismiss を発火）
    // 2回に1回表示（1回目は表示、2回目はスキップ、3回目は表示...）
    // 広告をスキップする偶数回目にはレビューダイアログをリクエストする。
    func presentInterstitial(onDismiss: @escaping () -> Void) {
        presentCount += 1
        guard presentCount % 2 == 1 else {
            print("⏭️: 今回は広告をスキップしました (\(presentCount)回目)")
            requestReview()
            onDismiss()
            return
        }

        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let root = windowScenes?.keyWindow?.rootViewController

        if let ad = interstitialAd, let root = root {
            self.onDismiss = onDismiss
            ad.present(from: root)
            self.interstitialAdLoaded = false
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.loadInterstitial()
            onDismiss()
        }
    }

    // 失敗通知
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        let dismiss = onDismiss
        onDismiss = nil
        dismiss?()
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false
    }

    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
        self.interstitialAd = nil
        self.loadInterstitial()
        // 広告ウィンドウが完全に破棄されてから遷移
        let dismiss = onDismiss
        onDismiss = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            dismiss?()
        }
    }

    // レビューダイアログをリクエストする（表示するかはOSが判断する）
    private func requestReview() {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                ?? scenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}
