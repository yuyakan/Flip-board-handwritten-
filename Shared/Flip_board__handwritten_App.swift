//
//  Flip_board__handwritten_App.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/28.
//

import SwiftUI
import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

func requestIDFA() {
  ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
    // Tracking authorization completed. Start loading ads here.
    // loadAd()
  })
}
 
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        requestIDFA()
        return true
    }
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
        // 設定の変更通知がされた時に呼ばれるデリゲート
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct Flip_board__handwritten_App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SelectView()
        }
    }
}
