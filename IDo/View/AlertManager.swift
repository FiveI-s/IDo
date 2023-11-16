//
//  AlertManager.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/14.
//

import UIKit

class AlertManager {
    // 정적 메서드로 구현 -> 인스턴스화 시키지 않아도 사용 가능
    static func showAlert(on viewController: UIViewController, title: String?, message: String?, action: ((UIAlertAction) -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: action)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showUpdateAlert(on viewController: UIViewController, title: String? = nil, message: String? = nil, updateHandler: ((UIAlertAction) -> Void)? = nil, deleteHandler: ((UIAlertAction) -> Void)? = nil, cancelHandelr: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "수정", style: .default, handler: updateHandler)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: deleteHandler)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelHandelr)
        alertController.addAction(updateAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showDeclaration(on viewController: UIViewController, title: String? = nil, message: String? = nil, declarationHandler: ((UIAlertAction) -> Void)? = nil, cancelHandelr: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let declarationAction = UIAlertAction(title: "신고하기", style: .destructive, handler: declarationHandler)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelHandelr)
        
        alertController.addAction(declarationAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showDeclarationActionSheet(on viewController: UIViewController, title: String, message: String, spamHandler: ((UIAlertAction) -> Void)? = nil, dislikeHandler: ((UIAlertAction) -> Void)? = nil, selfHarmHandler: ((UIAlertAction) -> Void)? = nil, illegalSaleHandler: ((UIAlertAction) -> Void)? = nil, nudityHandler: ((UIAlertAction) -> Void)? = nil, hateSpeechHandler: ((UIAlertAction) -> Void)? = nil, violenceHandler: ((UIAlertAction) -> Void)? = nil, bullyingHandler: ((UIAlertAction) -> Void)? = nil) {
        let actionSheetController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let spamAction = UIAlertAction(title: "스팸", style: .default, handler: spamHandler)
        
        let dislikeAction = UIAlertAction(title: "마음에 들지 않음", style: .default, handler: dislikeHandler)
        
        let selfHarmAction = UIAlertAction(title: "자살 및 자해", style: .default, handler: selfHarmHandler)
        
        let illegalSaleAction = UIAlertAction(title: "불법 상품 판매", style: .default, handler: illegalSaleHandler)
        
        let nudityAction = UIAlertAction(title: "나체 이미지 또는 성적 행위", style: .default, handler: nudityHandler)
        
        let hateSpeechAction = UIAlertAction(title: "혐오 발언 또는 상징", style: .default, handler: hateSpeechHandler)
        
        let violenceAction = UIAlertAction(title: "폭력 또는 위험한 단체", style: .default, handler: violenceHandler)
        
        let bullyingAction = UIAlertAction(title: "따돌림 또는 괴롭힘", style: .default, handler: bullyingHandler)
        
        // UIAlertAction들을 UIAlertController에 추가
        actionSheetController.addAction(spamAction)
        actionSheetController.addAction(dislikeAction)
        actionSheetController.addAction(selfHarmAction)
        actionSheetController.addAction(illegalSaleAction)
        actionSheetController.addAction(nudityAction)
        actionSheetController.addAction(hateSpeechAction)
        actionSheetController.addAction(violenceAction)
        actionSheetController.addAction(bullyingAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheetController.addAction(cancelAction)
        
        viewController.present(actionSheetController, animated: true, completion: nil)
    }
    
    static func showCheckDeclaration(on viewController: UIViewController, title: String, message: String, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive, handler: okHandler)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showIsNotClubMemberChek(on viewController: UIViewController) {
        
        let alertController = UIAlertController(title: "모임 회원이 아닙니다", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            if let navigationController = viewController.navigationController {
                for controller in navigationController.viewControllers {
                    if let meetingVC = controller as? MeetingViewController {
                        navigationController.popToViewController(meetingVC, animated: true)
                        break
                    }
                }
            }
        }
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

