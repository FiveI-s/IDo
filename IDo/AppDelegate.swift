//
//  AppDelegate.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/10.
//

import FirebaseCore
import KakaoSDKCommon
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        var firebasePlistName = "GoogleService-Info" // 기본 설정 파일 이름
        #if DEBUG
        firebasePlistName += "-Debug" // 개발용 Configuration
        print("[FIREBASE] Development mode.")
        #else
        firebasePlistName += "-Release" // 배포용 Configuration
        print("[FIREBASE] Production mode.")
        #endif
        
        if let filePath = Bundle.main.path(forResource: firebasePlistName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }

        // 카카오 초기화
//        KakaoSDK.initSDK(appKey: apiKey)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
