//
//  MyProfileUpdateManager.swift
//  IDo
//
//  Created by 김도현 on 2023/11/08.
//

import FirebaseDatabase

class MyProfileUpdateManager: FBDatabaseManager<IDoUser> {
    private let defaultRef = Database.database().reference()
    private let clubFirebaseManager = FirebaseClubDatabaseManager(refPath: [])
    
    // MARK: - 유저 업데이트
    func updateUser(idoUser: IDoUser, completion: ((Bool) -> Void)?) {
        updateValue(value: idoUser) { isSuccess in
            if isSuccess {
                idoUser.myClubList?.forEach({ club in
                    self.updateClub(idoUser: idoUser, club: club)
                })
                idoUser.myNoticeBoardList?.forEach({ noticeBoard in
                    self.updateNoticeBoard(noticeBoard: noticeBoard, idoUser: idoUser)
                })
                idoUser.myCommentList?.forEach({ comment in
                    self.updateComment(comment: comment, idoUser: idoUser)
                })
                completion?(true)
            }
        }
    }
    
    private func updateClub(idoUser: IDoUser, club: Club, completion: ((Bool) -> Void)? = nil) {
        let clubUserRef = defaultRef.child(club.category).child("meetings").child(club.id).child("userList")
        
        clubUserRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            guard let dataSnapShot = dataSnapShot?.value as? Array<Any> else {
                print("데이터가 존재하지 않습니다.")
                return
            }
            var idoUsers: [UserSummary] = dataSnapShot.compactMap{ DataModelCodable.decodingSingleDataSnapshot(value: $0)}
            guard let index = idoUsers.firstIndex(where: { $0.id == idoUser.id }) else {
                print("내 유저 정보를 찾을수 없습니다")
                return
            }
            //TODO: 지금은 급한대로 신고횟수는 건드리지 않도록 4번 연속으로 데이터를 각자 업데이트하지만 나중엔 idoUser.toUserSummary.dictionary를 한번에 업데이트 하도록 수정하기
            let descriptionRef = clubUserRef.child("\(index)").child("description")
            let idRef = clubUserRef.child("\(index)").child("id")
            let nickNameRef = clubUserRef.child("\(index)").child("nickName")
            let profileImagePathRef = clubUserRef.child("\(index)").child("profileImagePath")
            
            let userSummary = idoUser.toUserSummary
            descriptionRef.setValue(userSummary.description)
            idRef.setValue(userSummary.id)
            nickNameRef.setValue(userSummary.nickName)
            profileImagePathRef.setValue(userSummary.profileImagePath)
            completion?(true)
//            clubUserRef.updateChildValues(["\(index)": idoUser.toUserSummary.dictionary as Any]) { error, _ in
//                if let error {
//                    print(error.localizedDescription)
//                    completion?(false)
//                    return
//                }
//                completion?(true)
//            }
        }
        
        let clubRootUserRef = defaultRef.child(club.category).child("meetings").child(club.id).child("rootUser")
        if idoUser.id == club.rootUser.id {
            clubRootUserRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
                if let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateNoticeBoard(noticeBoard: NoticeBoard, idoUser: IDoUser) {
        let noticeBoardRef = defaultRef.child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
        noticeBoardRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
//            guard let dataSnapShot = dataSnapShot?.value else {
//                print("게시판 데이터를 가져오지 못했습니다")
//                return
//            }
            if let dataSnapShot,
               dataSnapShot.exists() {
                let noticeBoardRootUserRef = noticeBoardRef.child("rootUser")
                noticeBoardRootUserRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
                    if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func updateComment(comment: Comment, idoUser: IDoUser) {
        let commentRef = defaultRef.child("CommentList").child(comment.noticeBoardID).child(comment.id).child("writeUser")
        commentRef.setValue(idoUser.toUserSummary.dictionary) { error, _ in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - 유저 삭제
    func deleteUser(idoUser: IDoUser, completion: ((Bool) -> Void)?) {
        deleteValue(value: idoUser) { success in
            if success {
                idoUser.myClubList?.forEach({ club in
                    self.deleteClub(idoUser: idoUser, club: club)
                })
                idoUser.myNoticeBoardList?.forEach({ noticeBoard in
                    self.deleteNoticeBoard(noticeBoard: noticeBoard, idoUser: idoUser)
                })
                idoUser.myCommentList?.forEach({ comment in
                    self.deleteComment(comment: comment, idoUser: idoUser)
                    
                })
                completion?(true)
            }
        }
    }
    
    private func deleteClub(idoUser: IDoUser, club: Club, completion: ((Bool) -> Void)? = nil) {
        
        // 클럽 안에 있는 UserList에서 탈퇴한 회원 삭제하기
        let clubUserRef = defaultRef.child(club.category).child("meetings").child(club.id).child("userList")
        clubUserRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var userList = currentData.value as? [[String: Any]] {
                userList.removeAll { user in
                    if let userId = user["id"] as? String {
                        return userId == idoUser.id
                    }
                    return false
                }
                currentData.value = userList
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { error, _, _ in
            if let error = error {
                print(error.localizedDescription)
                print("클럽 유저 리스트 삭제 실패")
                completion?(false)
            } else {
                print("클럽 유저 리스트 삭제 성공")
                
                // 탈퇴한 회원이 만든 클럽 삭제하기
                if club.rootUser.id == idoUser.id {
                    let clubRootUserRef = self.defaultRef.child(club.category).child("meetings").child(club.id)
                    clubRootUserRef.getData { error, dataSnapShot in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }

                        guard let dataSnapShot = dataSnapShot?.value else {
                            print("데이터가 존재하지 않습니다.")
                            return
                        }
                        guard let club: Club = DataModelCodable.decodingSingleDataSnapshot(value: dataSnapShot) else { return }
                        self.clubFirebaseManager.removeClub(club: club, userList: club.userList ?? []) { success in
                            if success {
                                print("탈퇴 회원 관련 게시글,댓글 삭제 성공")
                            }
                        }
                    }
                }
                completion?(true)
            }
        }
        
        // 탈퇴한 회원이 만든 게시글 삭제하기
        let clubNoticeBoardListRef = defaultRef.child(club.category).child("meetings").child(club.id).child("noticeBoardList")
        clubNoticeBoardListRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var noticeBoardList = currentData.value as? [[String: Any]] {
                noticeBoardList.removeAll { noticeBoardDict in
                    if let rootUserDict = noticeBoardDict["rootUser"] as? [String: Any],
                       let rootUserId = rootUserDict["id"] as? String {
                        return rootUserId == idoUser.id
                    }
                    return false
                }
                currentData.value = noticeBoardList
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { error, _, _ in
            if let error = error {
                print(error.localizedDescription)
                print("클럽 게시글 삭제 실패")
                completion?(false)
            } else {
                print("클럽 게시글 삭제 성공")
                completion?(true)
            }
        }
    }
    
    private func deleteNoticeBoard(noticeBoard: NoticeBoard, idoUser: IDoUser) {
        let noticeBoardRef = defaultRef.child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
        
//        noticeBoardRef.child("rootUser").getData { error, dataSnapShot in
//            if let snapshotValue = dataSnapShot?.value as? [String: Any],
//               let rootUserId = snapshotValue["id"] as? String, rootUserId == idoUser.id {
//                noticeBoardRef.child("rootUser").removeValue { error, _ in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
        noticeBoardRef.getData { error, dataSnapShot in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshotValue = dataSnapShot?.value as? [String: Any],
               let rootUserDict = snapshotValue["rootUser"] as? [String: Any],
               let rootUserId = rootUserDict["id"] as? String, rootUserId == idoUser.id {
                noticeBoardRef.removeValue { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("게시판 삭제 성공")
                    }
                }
            } else {
                print("게시판 삭제 권한이 없습니다.")
            }
        }
    }
    
    private func deleteComment(comment: Comment, idoUser: IDoUser) {
        let commentRef = defaultRef.child("CommentList").child(comment.noticeBoardID).child(comment.id)
        
//        commentRef.child("writeUser").getData { error, dataSnapShot in
//            if let snapshotValue = dataSnapShot?.value as? [String: Any],
//               let writerUserId = snapshotValue["id"] as? String, writerUserId == idoUser.id {
//                commentRef.child("writeUser").removeValue { error, _ in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
        commentRef.getData { error, dataSnapShot in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshotValue = dataSnapShot?.value as? [String: Any],
               let rootUserDict = snapshotValue["writeUser"] as? [String: Any],
               let rootUserId = rootUserDict["id"] as? String, rootUserId == idoUser.id {
                commentRef.removeValue { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("댓글 삭제 성공")
                    }
                }
            } else {
                print("댓글 삭제 권한이 없습니다.")
            }
        }
    }
}
