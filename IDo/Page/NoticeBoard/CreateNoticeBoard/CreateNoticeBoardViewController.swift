//
//  CreateNoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import FirebaseDatabase

protocol RemoveDelegate: AnyObject {
    func removeCell(_ indexPath: IndexPath)
}

class CreateNoticeBoardViewController: UIViewController {
    
    let createNoticeBoardView = CreateNoticeBoardView()
    
    private var isTitleTextViewEdited = false
    private var isContentTextViewEdited = false
    
    var isEditingMode = false
    
    var editingTitleText: String?
    var editingContentText: String?
    
    var editingMemoIndex: Int?
    var editingImages: [String:UIImage]?
    
    var firebaseManager: FirebaseManager
    var club: Club
    
    init(club: Club, firebaseManager: FirebaseManager) {
        self.club = club
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(club: Club, firebaseManager: FirebaseManager, index: Int, images: [String:UIImage]) {
        self.init(club: club, firebaseManager: firebaseManager)
        self.editingMemoIndex = index
        self.editingImages = images
        self.isEditingMode = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = createNoticeBoardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationControllerSet()
        navigationBarButtonAction()
        
        buttonAction()
        
        createNoticeBoardView.titleTextView.delegate = self
        createNoticeBoardView.contentTextView.delegate = self
        
        createNoticeBoardView.galleryCollectionView.delegate = self
        createNoticeBoardView.galleryCollectionView.dataSource = self
        
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            firebaseManager.selectedImage.removeAll()
            firebaseManager.newSelectedImage.removeAll()
            isEditingMode = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.createNoticeBoardView.titleTextView.resignFirstResponder()
        self.createNoticeBoardView.contentTextView.resignFirstResponder()
    }
    
}

// MARK: - NavigationBar 관련 extension
private extension CreateNoticeBoardViewController {
    
    func navigationControllerSet() {
        self.title = "게시판 작성"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.view.tintColor = UIColor(named: "MainColor")
    }
    
    func navigationBarButtonAction() {
        
        // 수정 할 때
        if isEditingMode {
            if let editingTitleText = editingTitleText, let editingContentText = editingContentText {
                isTitleTextViewEdited = true
                isContentTextViewEdited = true
                
                // 제목 textView
                createNoticeBoardView.titleTextView.text = editingTitleText
                createNoticeBoardView.titleTextView.textColor = UIColor.black
                
                // 내용 textView
                createNoticeBoardView.contentTextView.text = editingContentText
                createNoticeBoardView.contentTextView.textColor = UIColor.black
                
                // 제목 글자 수 반영
                createNoticeBoardView.titleCountLabel.text = "(\(editingTitleText.count)/16)"
                createNoticeBoardView.titleCountLabel.textColor = .black
                
                // 제목 글자 수 반영
                createNoticeBoardView.contentCountLabel.text = "(\(editingContentText.count)/500)"
                createNoticeBoardView.contentCountLabel.textColor = .black
            }
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedEdit))
            self.navigationItem.rightBarButtonItem = finishButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        
        // 처음 작성 할 때
        else {
            // 제목 textView
            self.createNoticeBoardView.titleTextView.text = "제목을 입력하세요."
            self.createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
            self.createNoticeBoardView.titleTextView.resignFirstResponder()
            
            // 내용 textView
            self.createNoticeBoardView.contentTextView.text = "내용을 입력하세요."
            self.createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
            self.createNoticeBoardView.contentTextView.resignFirstResponder()
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedNew))
            self.navigationItem.rightBarButtonItem = finishButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 새로운 메모 작성
    @objc func finishButtonTappedNew() {
        
        if isTitleTextViewEdited && isContentTextViewEdited {
            guard let newTitleText = createNoticeBoardView.titleTextView.text else { return }
            guard let newContentText = createNoticeBoardView.contentTextView.text else { return }
            
            firebaseManager.createNoticeBoard(title: newTitleText, content: newContentText) { success in
                if success {
                    print("게시판 생성 성공")
                }
                else {
                    print("게시판 생성 실패")
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
        firebaseManager.selectedImage.removeAll()
    }
    
    // 메모 내용 수정
    @objc func finishButtonTappedEdit() {
        
        if let updateTitle = createNoticeBoardView.titleTextView.text, !updateTitle.isEmpty,
           let updateContent = createNoticeBoardView.contentTextView.text, !updateContent.isEmpty,
           let index = editingMemoIndex {
            
            // 해당 인덱스의 메모 수정 코드 필요
            firebaseManager.updateNoticeBoard(at: index, title: updateTitle, content: updateContent) { success in
                if success {
                    print("업데이트 완료")
                }
            }
            
            // 수정된 메모 내용을 업데이트하고 해당 셀만 리로드
            (self.navigationController?.viewControllers.first as? NoticeBoardView)?.noticeBoardTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        // 수정 모드 종료
        isEditingMode = false
        navigationController?.popViewController(animated: true)
        firebaseManager.selectedImage.removeAll()
    }
}

// MARK: - TextView 관련
extension CreateNoticeBoardViewController: UITextViewDelegate {
    
    // 애니메이션 함수
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }
    
    // 초기 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // 제목 textView
        if textView == createNoticeBoardView.titleTextView {
            if createNoticeBoardView.titleTextView.textColor == UIColor(color: .placeholder) {
                
                createNoticeBoardView.titleTextView.text = nil
                createNoticeBoardView.titleTextView.textColor = UIColor.black
            }
        }
        
        // 내용 textView
        if textView == createNoticeBoardView.contentTextView {
            if createNoticeBoardView.contentTextView.textColor == UIColor(color: .placeholder) {
                
                createNoticeBoardView.contentTextView.text = nil
                createNoticeBoardView.contentTextView.textColor = UIColor.black
            }
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == createNoticeBoardView.titleTextView {
            let textCount = textView.text.count
            createNoticeBoardView.titleCountLabel.text = "(\(textCount)/16)"
            
            if textCount == 0 {
                createNoticeBoardView.titleCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                createNoticeBoardView.titleCountLabel.textColor = UIColor.black
            }
        }
        
        if textView == createNoticeBoardView.contentTextView {
            let textCount = textView.text.count
            createNoticeBoardView.contentCountLabel.text = "(\(textCount)/500)"
            
            if textCount == 0 {
                createNoticeBoardView.contentCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                createNoticeBoardView.contentCountLabel.textColor = UIColor.black
            }
        }
        
        // 제목 textView에 내용이 있는 경우
        if createNoticeBoardView.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.titleTextView.textColor == UIColor.black {
            isTitleTextViewEdited = true
        }
        
        // 내용 textView에 내용이 있는 경우
        if createNoticeBoardView.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.contentTextView.textColor == UIColor.black{
            isContentTextViewEdited = true
        }
        
        // 제목과 내용이 모두 있으면 "완료" 버튼 활성화
        self.navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if createNoticeBoardView.titleTextView.text.isEmpty {
            createNoticeBoardView.titleTextView.text =  "제목을 입력하세요."
            createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
        }
        
        if createNoticeBoardView.contentTextView.text.isEmpty {
            createNoticeBoardView.contentTextView.text =  "내용을 입력하세요."
            createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == createNoticeBoardView.titleTextView {
            if changedText.count > 16 {
                createNoticeBoardView.titleCountLabel.textColor = UIColor.red
                shakeAnimation(for: createNoticeBoardView.titleCountLabel)
                return false
            }
            return true
        }
        
        if textView == createNoticeBoardView.contentTextView {
            if changedText.count > 500 {
                createNoticeBoardView.contentCountLabel.textColor = UIColor.red
                shakeAnimation(for: createNoticeBoardView.contentCountLabel)
                return false
            }
            return true
        }
        return true
    }
}

// MARK: - addPictureButton 관련
private extension CreateNoticeBoardViewController {
    
    func buttonAction() {
        createNoticeBoardView.addPictureButton.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
    }
    
    @objc func addPicture() {
        if firebaseManager.selectedImage.count < 10 {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            AlertManager.showAlert(on: self, title: "알림", message: "10장의 사진까지 게시 할 수 있습니다.")
        }
    }
}

extension CreateNoticeBoardViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
//            if isEditingMode {
//                firebaseManager.newSelectedImage.append(image)
//            }
//            else {
//                firebaseManager.selectedImage.append(image)
//            }
//            firebaseManager.selectedImage += firebaseManager.newSelectedImage
            
            // 딕셔너리에 추가하는 코드 작성
            let index = firebaseManager.selectedImage.count
            firebaseManager.selectedImage[String(index)] = image
            // 업데이트된 이미지 배열로 컬렉션 뷰를 새로고침
            createNoticeBoardView.galleryCollectionView.reloadData()
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - 사진 CollectionView 관련
extension CreateNoticeBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firebaseManager.selectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        cell.createNoticeBoardImagePicker.galleryImageView.image = firebaseManager.selectedImage[String(indexPath.row)]
        cell.removeCellDelegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    
}

extension CreateNoticeBoardViewController: UICollectionViewDelegateFlowLayout {
    
    // CollectionView Cell의 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8)/5, height: (collectionView.bounds.width - 8)/5)
    }
    
    // 수평
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 수직
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

// MARK: - Navigation 관련
extension CreateNoticeBoardViewController: UINavigationControllerDelegate {

}

// MARK: - 사진 삭제 관련
extension CreateNoticeBoardViewController: RemoveDelegate {
    
    func removeLocal(_ indexPath: IndexPath) {
        // 로컬에서 이미지를 삭제하고 Collection View를 업데이트
        self.createNoticeBoardView.galleryCollectionView.performBatchUpdates {
            
            // 선택된 인덱스에 해당하는 이미지를 딕셔너리에서 삭제
            self.firebaseManager.selectedImage[String(indexPath.row)] = nil
            
            // 해당하는 아이템을 CollectionView에서 삭제
            self.createNoticeBoardView.galleryCollectionView.deleteItems(at: [indexPath])
        } completion: { _ in
            
            // 딕셔너리의 키를 재정렬
            var newSelectedImage: [String: UIImage] = [:]
            let sortedKeys = self.firebaseManager.selectedImage.keys.compactMap { Int($0) }.sorted()
            
            // 재정렬할 때 사용할 새 인덱스
            var newIndex = 0
            
            for key in sortedKeys {
                if let image = self.firebaseManager.selectedImage[String(key)] {
                    newSelectedImage[String(newIndex)] = image
                    newIndex += 1
                }
            }
            
            // 재정렬된 이미지 딕셔너리를 업데이트
            self.firebaseManager.selectedImage = newSelectedImage
            
            // self.createNoticeBoardView.galleryCollectionView.reloadData()
        }
    }

    func removeCell(_ indexPath: IndexPath) {
        
        // 게시글을 수정할 때
        if isEditingMode {
            
            // storage에 이미지가 있을 때
            if let editingMemoIndex = editingMemoIndex,
               let imageList = firebaseManager.noticeBoards[editingMemoIndex].imageList,
               indexPath.row < imageList.count {
                
                let imagePath = imageList[indexPath.row]
                
                // Firebase Storage에서 이미지를 삭제
                firebaseManager.deleteImage(noticeBoardID: firebaseManager.noticeBoards[editingMemoIndex].id, imagePaths: [imagePath]) { success in
                    self.removeLocal(indexPath)
                    
                }
            }
            
            // storage에 이미지가 없을 때
            else {
                removeLocal(indexPath)
            }
        }
        
        // 처음 게시글을 작성할 때
        else {
            removeLocal(indexPath)
        }
    }
}
