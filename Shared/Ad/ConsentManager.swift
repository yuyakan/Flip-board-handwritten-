//
//  ConsentManager.swift
//  Flip board -handwritten-
//
//  UMP（同意管理）+ ATT（トラッキング許可）の取得を担当する。
//  推奨フロー: 同意情報取得 → 必要ならUMPフォーム表示 → ATT要求 → 広告初期化
//

import AppTrackingTransparency
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

@MainActor
final class ConsentManager {
    static let shared = ConsentManager()

    private var didStartMobileAds = false

    private init() {}

    /// 起動時に呼ぶ。UMP同意 → ATT → Mobile Ads SDK 起動までを一括で行う。
    func gatherConsentAndStartAds() {
        let parameters = RequestParameters()
        // 本番では nil。テスト時はここに DebugSettings を設定して地域(EEA等)を強制できる。
        // parameters.debugSettings = ...

        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            guard let self else { return }
            if let error {
                print("😭: 同意情報の取得に失敗しました: \(error.localizedDescription)")
            }

            Task { @MainActor in
                await self.presentFormIfNeeded()
                await self.requestTrackingAuthorization()
                self.startMobileAdsIfNeeded()
            }
        }
    }

    /// UMPフォームが必要なら表示する。不要なら即座に返る。
    private func presentFormIfNeeded() async {
        guard let root = Self.rootViewController else { return }
        do {
            try await ConsentForm.loadAndPresentIfRequired(from: root)
        } catch {
            print("😭: 同意フォームの表示に失敗しました: \(error.localizedDescription)")
        }
    }

    /// ATTのトラッキング許可を要求する。完了までは広告の初期化を待つ。
    private func requestTrackingAuthorization() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    /// Mobile Ads SDK を一度だけ起動する。
    private func startMobileAdsIfNeeded() {
        guard !didStartMobileAds else { return }
        guard ConsentInformation.shared.canRequestAds else {
            print("ℹ️: 同意が得られていないため広告は初期化しません")
            return
        }
        didStartMobileAds = true
        MobileAds.shared.start(completionHandler: nil)
    }

    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow?
            .rootViewController
    }
}
