//
//  LoginViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import Firebase

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let mainBarController = TabBarController()
    
    var kakaoEmail: String = ""
    var kakaoPassword: String = ""
    
    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clickLoginButton()
    }

}

private extension LoginViewController {
    
    func clickLoginButton() {
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
    }
    
    @objc func kakaoLogin() {
        // MARK: - 카카오톡 앱으로 로그인
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    
                    self.getUserInfo()
                }
            }
        }
        
        // MARK: - 카카오톡 계정으로 로그인
        else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    _ = oauthToken
                    
                    self.getUserInfo()
                }
            }
        }
    }
    
    // MARK: - 카카오로 로그인한 사용자 정보 가져오기
    private func getUserInfo() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                
                //do something
                _ = user
                if let email = user?.kakaoAccount?.email {
                    self.kakaoEmail = email
                }
                if let id = user?.id {
                    self.kakaoPassword = String(id)
                }
                self.regiSterFirebase(email: self.kakaoEmail, password: self.kakaoPassword)
            }
        }
    }
    
    // MARK: - Firebase 등록
    private func regiSterFirebase(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            // Error(등록 실패)
            if let e = error {
                print(e.localizedDescription)
            }
            
            // Success(등록 성공)
            else {
                self.loginFirebase(email: email, password: password)
            }
        }
    }
    
    // MARK: - Firebase 로그인
    private func loginFirebase(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            // Error(등록 실패)
            if let e = error {
                print(e.localizedDescription)
            }
            // Success(등록 성공)
            else {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(self.mainBarController, animated: true)
            }
        }
    }
}
