//
//  CreateNoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import FirebaseDatabase
import UIKit

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
    
    var firebaseManager: FirebaseManager
    var club: Club
    
    init(club: Club, firebaseManager: FirebaseManager) {
        self.club = club
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(club: Club, firebaseManager: FirebaseManager, index: Int) {
        self.init(club: club, firebaseManager: firebaseManager)
        self.editingMemoIndex = index
        self.isEditingMode = true
    }
    
    @available(*, unavailable)
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
        updateAutolayoutCollectionView()
        
        buttonAction()
        
        createNoticeBoardView.titleTextView.delegate = self
        createNoticeBoardView.contentTextView.delegate = self
        
        createNoticeBoardView.galleryCollectionView.delegate = self
        createNoticeBoardView.galleryCollectionView.dataSource = self
        
        navigationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        if firebaseManager.isClubExists == false {
            AlertManager.showAlert(on: self, title: "클럽이 존재하지 않습니다", message: nil) { _ in
                if let navigationController = self.navigationController {
                    for controller in navigationController.viewControllers {
                        if let meetingVC = controller as? MeetingViewController {
                            navigationController.popToViewController(meetingVC, animated: true)
                            break
                        }
                    }
                    navigationController.popToRootViewController(animated: true)
                }
            }
        }
        guard MyProfile.shared.isJoin(in: firebaseManager.club) else {
            AlertManager.showIsNotClubMemberChek(on: self)
            return
        }
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            firebaseManager.selectedImage.removeAll()
            firebaseManager.newSelectedImage.removeAll()
            firebaseManager.removeSelecteImage.removeAll()
            firebaseManager.missSelectedImage.removeAll()
            isEditingMode = false
        }
        guard MyProfile.shared.isJoin(in: firebaseManager.club) else {
            AlertManager.showIsNotClubMemberChek(on: self)
            return
        }
        removeKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        createNoticeBoardView.titleTextView.resignFirstResponder()
        createNoticeBoardView.contentTextView.resignFirstResponder()
    }
}

// MARK: - KeyBoard 관련 extension

private extension CreateNoticeBoardViewController {
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let adjustmentHeight = keyboardHeight - (tabBarController?.tabBar.frame.size.height ?? 0)
        
        createNoticeBoardView.scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-adjustmentHeight)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        createNoticeBoardView.scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - NavigationBar 관련 extension

private extension CreateNoticeBoardViewController {
    func navigationControllerSet() {
        if isEditingMode {
            if let navigationBar = navigationController?.navigationBar {
                NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "게시판 수정")
            }
        }
        else {
            if let navigationBar = navigationController?.navigationBar {
                NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "게시판 작성")
            }
        }
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.view.tintColor = UIColor.black
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
                
                // 내용 글자 수 반영
                createNoticeBoardView.contentCountLabel.text = "(\(editingContentText.count)/500)"
                createNoticeBoardView.contentCountLabel.textColor = .black
            }
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedEdit))
            navigationItem.rightBarButtonItem = finishButton
            navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        
        // 처음 작성 할 때
        else {
            // 제목 textView
            createNoticeBoardView.titleTextView.text = "제목을 입력하세요."
            createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
            createNoticeBoardView.titleTextView.resignFirstResponder()
            
            // 내용 textView
            createNoticeBoardView.contentTextView.text = "내용을 입력하세요."
            createNoticeBoardView.contentTextView.textColor = UIColor(color: .placeholder)
            createNoticeBoardView.contentTextView.resignFirstResponder()
            
            // 네비게이션 바 오른쪽 버튼 커스텀 -> 완료
            let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishButtonTappedNew))
            navigationItem.rightBarButtonItem = finishButton
            navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        }
        navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 새로운 메모 작성
    @objc func finishButtonTappedNew() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if isTitleTextViewEdited, isContentTextViewEdited {
            guard let newTitleText = createNoticeBoardView.titleTextView.text else { return }
            guard let newContentText = createNoticeBoardView.contentTextView.text else { return }
            
            firebaseManager.createNoticeBoard(title: newTitleText, content: newContentText) { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                    print("게시판 생성 성공")
                }
                else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("게시판 생성 실패")
                }
            }
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // 메모 내용 수정
    @objc func finishButtonTappedEdit() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if let updateTitle = createNoticeBoardView.titleTextView.text, !updateTitle.isEmpty,
           let updateContent = createNoticeBoardView.contentTextView.text, !updateContent.isEmpty,
           let index = editingMemoIndex
        {
            firebaseManager.updateNoticeBoard(at: index, title: updateTitle, content: updateContent) { success in
                if success {
                    self.isEditingMode = false
                    (self.navigationController?.viewControllers.first as? NoticeBoardView)?.noticeBoardTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    self.navigationController?.popViewController(animated: true)
                    print("업데이트 완료")
                }
                else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("업데이트 실패")
                }
            }
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
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
            }
            else {
                createNoticeBoardView.titleCountLabel.textColor = UIColor.black
            }
        }
        
        if textView == createNoticeBoardView.contentTextView {
            let textCount = textView.text.count
            createNoticeBoardView.contentCountLabel.text = "(\(textCount)/500)"
            
            if textCount == 0 {
                createNoticeBoardView.contentCountLabel.textColor = UIColor(color: .placeholder)
            }
            else {
                createNoticeBoardView.contentCountLabel.textColor = UIColor.black
            }
        }
        
        // 제목 textView에 내용이 있는 경우
        if createNoticeBoardView.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.titleTextView.textColor == UIColor.black {
            isTitleTextViewEdited = true
        }
        
        // 내용 textView에 내용이 있는 경우
        if createNoticeBoardView.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0, createNoticeBoardView.contentTextView.textColor == UIColor.black {
            isContentTextViewEdited = true
        }
        
        // 제목과 내용이 모두 있으면 "완료" 버튼 활성화
        navigationItem.rightBarButtonItem?.isEnabled = isTitleTextViewEdited && isContentTextViewEdited
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        if createNoticeBoardView.titleTextView.text.isEmpty {
            createNoticeBoardView.titleTextView.text = "제목을 입력하세요."
            createNoticeBoardView.titleTextView.textColor = UIColor(color: .placeholder)
        }
        
        if createNoticeBoardView.contentTextView.text.isEmpty {
            createNoticeBoardView.contentTextView.text = "내용을 입력하세요."
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
        if firebaseManager.newSelectedImage.count < 10 {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
//            if isEditingMode {
//                firebaseManager.newSelectedImage.append(image)
//            }
//            else {
//                firebaseManager.selectedImage.append(image)
//            }
//            firebaseManager.selectedImage += firebaseManager.newSelectedImage
            
            // 딕셔너리에 추가하는 코드 작성
//            let index = firebaseManager.selectedImage.count
//            firebaseManager.selectedImage[String(index)] = image
            let index = firebaseManager.newSelectedImage.count
            firebaseManager.newSelectedImage[String(index)] = StorageImage(imageUID: UUID().uuidString, savedImage: image)
            
            // 업데이트된 이미지 배열로 컬렉션 뷰를 새로고침
            DispatchQueue.main.async {
                self.createNoticeBoardView.galleryCollectionView.insertItems(at: [IndexPath(row: index, section: 0)])
                self.updateAutolayoutCollectionView()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - 사진 CollectionView 관련

extension CreateNoticeBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firebaseManager.newSelectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        cell.createNoticeBoardImagePicker.galleryImageView.image = firebaseManager.newSelectedImage[String(indexPath.row)]?.savedImage
        cell.removeCellDelegate = self
        cell.indexPath = indexPath
        return cell
    }
}

// MARK: - CollectionView AutoLayout Update

extension CreateNoticeBoardViewController {
    func updateAutolayoutCollectionView() {
        DispatchQueue.main.async {
            if self.firebaseManager.newSelectedImage.count == 0 {
                self.createNoticeBoardView.galleryCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                return
            }
            let rows = ceil(CGFloat(self.firebaseManager.newSelectedImage.count) / 5.0)
            let spacing = rows * 2
            let cellHeight = (self.createNoticeBoardView.galleryCollectionView.bounds.width - 8) / 5
            let contentHeight = rows * cellHeight + spacing
            self.createNoticeBoardView.galleryCollectionView.snp.updateConstraints { make in
                make.height.equalTo(contentHeight)
            }
        }
    }
}

extension CreateNoticeBoardViewController: UICollectionViewDelegateFlowLayout {
    // CollectionView Cell의 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8) / 5, height: (collectionView.bounds.width - 8) / 5)
    }
    
    // 수평 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 수직 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

// MARK: - Navigation 관련

extension CreateNoticeBoardViewController: UINavigationControllerDelegate {}

// MARK: - 사진 삭제 관련

extension CreateNoticeBoardViewController: RemoveDelegate {
    //    func removeLocal(_ indexPath: IndexPath) {
    //            // 로컬에서 이미지를 삭제하고 Collection View를 업데이트
    //            self.createNoticeBoardView.galleryCollectionView.performBatchUpdates {
    //
    //                // 선택된 인덱스에 해당하는 이미지를 딕셔너리에서 삭제
    //                self.firebaseManager.selectedImage[String(indexPath.row)] = nil
    //
    //                // 해당하는 아이템을 CollectionView에서 삭제
    //                self.createNoticeBoardView.galleryCollectionView.deleteItems(at: [indexPath])
    //            } completion: { _ in
    //
    //                // 딕셔너리의 키를 재정렬
    //                var newSelectedImage: [String: UIImage] = [:]
    //                let sortedKeys = self.firebaseManager.selectedImage.keys.compactMap { Int($0) }.sorted()
    //
    //                // 재정렬할 때 사용할 새 인덱스
    //                var newIndex = 0
    //
    //                for key in sortedKeys {
    //                    if let image = self.firebaseManager.selectedImage[String(key)] {
    //                        newSelectedImage[String(newIndex)] = image
    //                        newIndex += 1
    //                    }
    //                }
    //
    //                // 재정렬된 이미지 딕셔너리를 업데이트
    //                self.firebaseManager.selectedImage = newSelectedImage
    //
    //                self.createNoticeBoardView.galleryCollectionView.reloadData()
    //            }
    //        }

    func removeLocal(_ indexPath: IndexPath) {
        guard let removeImage = firebaseManager.newSelectedImage[String(indexPath.row)] else {
            print("삭제할 이미지를 찾을 수 없음")
            return
        }
        
        firebaseManager.removeSelecteImage.append(removeImage)
        
        // 딕셔너리에서 이미지를 삭제
        firebaseManager.newSelectedImage.removeValue(forKey: String(indexPath.row))
        
        // Collection View에서 해당 아이템을 삭제
        createNoticeBoardView.galleryCollectionView.performBatchUpdates {
            self.createNoticeBoardView.galleryCollectionView.deleteItems(at: [indexPath])
        } completion: { [weak self] _ in
            guard let self = self else { return }
            
            // 변경된 인덱스를 추적하기 위한 배열
            var updatedIndexPaths: [IndexPath] = []
            
            // 딕셔너리의 키를 재정렬하고, 업데이트할 인덱스를 계산
            let newSelectedImage = self.reorderSelectedImages(startingFrom: indexPath.row, updatedIndexPaths: &updatedIndexPaths)
            
            // 재정렬된 이미지 딕셔너리를 업데이트
            self.firebaseManager.newSelectedImage = newSelectedImage
            
            // 변경된 인덱스에 대해서만 컬렉션 뷰 업데이트
            self.createNoticeBoardView.galleryCollectionView.reloadItems(at: updatedIndexPaths)
        }
    }

    func reorderSelectedImages(startingFrom index: Int, updatedIndexPaths: inout [IndexPath]) -> [String: StorageImage] {
        var newSelectedImage: [String: StorageImage] = [:]
        var newIndex = 0
        
        // 삭제된 인덱스 이후의 아이템들을 업데이트하기 위한 인덱스 경로를 저장
        for i in index ..< firebaseManager.newSelectedImage.count {
            updatedIndexPaths.append(IndexPath(item: i, section: 0))
        }
        
        // 정렬된 딕셔너리를 반복하며 새로운 인덱스를 할당
        for (_, image) in firebaseManager.newSelectedImage.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            newSelectedImage[String(newIndex)] = image
            newIndex += 1
        }
        
        return newSelectedImage
    }
    
    func removeCell(_ indexPath: IndexPath) {
        // 게시글을 수정할 때
//        if isEditingMode {
//
//            // storage에 이미지가 있을 때
//            if let editingMemoIndex = editingMemoIndex,
//               let imageList = firebaseManager.noticeBoards[editingMemoIndex].imageList,
//               indexPath.row < imageList.count {
//
//                let imagePath = imageList[indexPath.row]
//
//                // Firebase Storage에서 이미지를 삭제
//                firebaseManager.deleteImage(noticeBoardID: firebaseManager.noticeBoards[editingMemoIndex].id, imagePaths: [imagePath]) { success in
//                    self.removeLocal(indexPath)
//
//                }
//            }
//
//            // storage에 이미지가 없을 때
//            else {
//                removeLocal(indexPath)
//            }
//        }
//
//        // 처음 게시글을 작성할 때
//        else {
//            removeLocal(indexPath)
//        }
        removeLocal(indexPath)
    }
}
