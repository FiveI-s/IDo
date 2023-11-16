//
//  SceneDelegate.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/10.
//

import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)

//        try? Auth.auth().signOut()
        if let uid = Auth.auth().currentUser?.uid {
            MyProfile.shared.getUserProfile(uid: uid) { isSuccess in
                if isSuccess {
                    window.rootViewController = TabBarController()
                } else {
                    window.rootViewController = LoginViewController()
                }
            }
        } else {
            window.rootViewController = LoginViewController()
        }
        window.backgroundColor = .white

        // 카카오 로그인 토큰이 있는지 여부 확인
//        if AuthApi.hasToken() {
//            UserApi.shared.accessTokenInfo { _, error in
//                if let error = error {
//                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
//                        // 로그인 필요
//                        let mainVC = LoginViewController()
//                        window.rootViewController = mainVC
//                    }
//                    else {
//                        // 기타 에러
//                        print(error.localizedDescription)
//                    }
//                }
//                else {
//                    // 토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
        ////                    self.getUserInfo()
        ////                    let mainVC = TabBarController()
        ////                    window.rootViewController = mainVC
        ////                    window.rootViewController = UINavigationController(rootViewController: SignUpViewController())
//
//                }
//            }
//        }
//        else {
//            // 로그인 필요
//            let mainVC = LoginViewController()
//            window.rootViewController = mainVC
//        }

        window.makeKeyAndVisible()
        self.window = window
    }

    // 카카오 사용자 정보 가져오기
    private func getUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error)
            } else {
                print("me() success.")

                // do something
                _ = user
                if let email = user?.kakaoAccount?.email,
                   let id = user?.id
                {
                    let password = String(id)
                    Auth.auth().signIn(withEmail: email, password: password)
                }
            }
        }
    }

    // 카카오톡을 통한 사용자 인증에 필요한 함수
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    // rootVC를 바꾸기 위한 함수
    func changeRootVC(_ vc: UIViewController, animated: Bool) {
        guard let window = window else { return }
        window.rootViewController = vc

        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
    }
}
