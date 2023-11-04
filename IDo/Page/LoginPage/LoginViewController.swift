//
//  LoginViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import Firebase
import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKUser
import UIKit

class LoginViewController: UIViewController {
    private let loginView = LoginView()
    private let fbUserDatabaseManager: FBDatabaseManager<IDoUser> = FBDatabaseManager(refPath: ["Users"])
    var kakaoEmail: String = ""
    var kakaoPassword: String = ""

    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.signUpRightLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signUp))
        loginView.signUpRightLabel.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
        clickLoginButton()
        clickDefaultLoginButton()
//        clickSignupButton()
    }
}

private extension LoginViewController {
//    func clickSignupButton() {
//        loginView.signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
//    }
    
    @objc func signUp() {
        let signUpVC = UINavigationController(rootViewController: SignUpViewController())
        signUpVC.modalPresentationStyle = .fullScreen
        present(signUpVC, animated: true)
    }
    
    // 화면 터치 시 키보드 내려가게 구현
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func clickDefaultLoginButton() {
        loginView.loginButton.addTarget(self, action: #selector(firebaseLogin), for: .touchUpInside)
    }
    
    @objc func firebaseLogin() {
        guard let email = loginView.emailTextField.text, !email.isEmpty else {
            showAlert(message: "이메일을 입력해주세요")
            return
        }
        guard let password = loginView.passwordTextField.text, !password.isEmpty else {
            showAlert(message: "비밀번호를 입력해주세요")
            return
        }
        loginFirebase(email: email, password: password)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func clickLoginButton() {
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
    }
    
    @objc func kakaoLogin() {
        // MARK: - 카카오톡 앱으로 로그인
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    
                    // do something
                    _ = oauthToken
                    
                    self.getUserInfo()
                }
            }
        }
        
        // MARK: - 카카오톡 계정으로 로그인
        
        else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    // do something
                    _ = oauthToken
                    
                    self.getUserInfo()
                }
            }
        }
    }
    
    // MARK: - 카카오로 로그인한 사용자 정보 가져오기
    
    private func getUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                
                // do something
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
                guard let user = authResult?.user else { return }
                let idoUser = IDoUser(id: user.uid, email: email, nickName: "name", hobbyList: [], myClubList: [], myNoticeBoardList: [], myCommentList: [])
                self.fbUserDatabaseManager.appendData(data: idoUser)
                self.loginFirebase(email: email, password: password)
            }
        }
    }
    
    // MARK: - Firebase 로그인
    
    private func loginFirebase(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authData, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showAlert(on: self, title: "알림", message: "이메일과 비밀번호를 다시 확인해주세요.")
                print(error.localizedDescription)
            }
            else {
                guard let uid = authData?.user.uid else { return }
                MyProfile.shared.getUserProfile(uid: uid) { isSuccess in
                    if isSuccess {
                        if let hobbyList = MyProfile.shared.myUserInfo?.hobbyList, !hobbyList.isEmpty {
                            let mainBarController = TabBarController()
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mainBarController, animated: true)
                        }
                        else {
                            if let navigationController = self.navigationController {
                                let categorySelectVC = CategorySelectViewController(email: email, password: password)
                                navigationController.pushViewController(categorySelectVC, animated: true)
                            }
                            else {
                                let categorySelectVC = CategorySelectViewController(email: email, password: password)
                                let navigationController = UINavigationController(rootViewController: categorySelectVC)
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(navigationController, animated: true)
                            }
                        }
                    } else {
                        print("로그인 정보를 불러오지 못했습니다.")
                    }
                }
            }
        }
    }
}
