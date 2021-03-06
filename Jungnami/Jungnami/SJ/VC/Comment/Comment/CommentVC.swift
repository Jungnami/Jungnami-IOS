//
//  CommentVC.swift
//
//  Created by 강수진 on 2018. 4. 30..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit

class CommentVC: UIViewController, APIService {
    
    // 화면 터치했을 때 키보드 사라지게 하는 gesture
    var keyboardDismissGesture: UITapGestureRecognizer?
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var commentSendView: UIView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var commentCountLbl: UILabel!
    
    var heartCount = 0
    var commentCount = 0
    var isCommunity = true
    var selectedBoard : Int? {
        didSet {
            if let selectedBoard_ = selectedBoard {
                let url = isCommunity ? UrlPath.BoardCommentList.getURL(selectedBoard_.description) : UrlPath.ContentCommentList.getURL(selectedBoard_.description)
                getCommentList(url: url)
            }
            
        }
    }
    var commentData : [CommunityCommentVOData] = []
    @IBAction func dissmissBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func writeCommentBtn(_ sender: Any) {
        let url = isCommunity ? UrlPath.BoardCommentList.getURL() : UrlPath.WriteContentComment.getURL()
        writeComment(url : url)
        commentTxt.text = ""
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.tableFooterView = UIView(frame : .zero)
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.tableFooterView = UIView(frame : .zero)
        setKeyboardSetting()
        likeCountLbl.text = "\(heartCount)명이 좋아합니다"
        likeCountLbl.sizeToFit()
        commentCountLbl.text = "\(commentCount)개"
        if let selectedBoard_ = selectedBoard {
            let url = isCommunity ? UrlPath.BoardCommentList.getURL(selectedBoard_.description) : UrlPath.ContentCommentList.getURL(selectedBoard_.description)
            getCommentList(url: url)
        }
        commentTxt.layer.cornerRadius = commentTxt.frame.height/2
        commentTxt.clipsToBounds = true 
        
    }
    
}

extension CommentVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        guard commentData.count > 0 else {return cell}
        
        cell.commentLikeBtn.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        cell.configure(index : indexPath.row ,data: commentData[indexPath.row])
        
        
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let selectedComment = commentData[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .normal, title: "삭제") { (rowAction, indexPath) in
            let commentIdx = selectedComment.commentid
            let url = self.isCommunity ?  UrlPath.BoardCommentList.getURL(commentIdx.description) : UrlPath.ContentCommentList.getURL(commentIdx.description)
            self.deleteComment(url: url)
            
        }
        deleteAction.backgroundColor = .red
        
        let reportAction = UITableViewRowAction(style: .normal, title: "신고") { (rowAction, indexPath) in
            let commentIdx = selectedComment.commentid
            self.reportAction(reportId: commentIdx, reportHandler: { (reportReason) in
            
                let relation = self.isCommunity ? ReportCategory.communityComment.rawValue : ReportCategory.contentComment.rawValue
                let params : [String : Any] = [
                    "relation" : relation,
                    
                    "relation_id" : commentIdx,
                    "content" : reportReason
                ]
                
              
                self.reportAction(url: UrlPath.Report.getURL(), parmas: params)
            })
        }
        return [deleteAction, reportAction]
    }
    
    
    
    @objc func like(_ sender : myHeartBtn){
        //통신
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.detailTableView)
        let indexPath: IndexPath? = self.detailTableView.indexPathForRow(at: buttonPosition)
        let cell = self.detailTableView.cellForRow(at: indexPath!) as! CommentCell
        
        if sender.isLike! == 0 {
            let url = isCommunity ? UrlPath.LikeBoardComment.getURL() : UrlPath.LikeContentComment.getURL()
            likeAction(url: url, boardIdx : sender.boardIdx!, isLike : sender.isLike!, cell : cell, sender : sender, likeCnt: sender.likeCnt )
        } else {
            let url = isCommunity ? UrlPath.LikeBoardComment.getURL(sender.boardIdx!.description) : UrlPath.LikeContentComment.getURL(sender.boardIdx!.description)
            dislikeAction(url: url, cell : cell, sender : sender, likeCnt: sender.likeCnt )
        }
        
    }
    
    
}

//키보드
extension CommentVC {
    func setKeyboardSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustKeyboardDismissGesture(isKeyboardVisible: true)
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.detailTableView.contentInset.bottom = keyboardSize.height
            ////////
            //////// 키보드의 사이즈만큼 commentSendView의 y축을 위로 이동시킴 ////////
           
            commentSendView.snp.remakeConstraints({ (make) in
                make.bottom.equalToSuperview().offset(-keyboardSize.height)
            })
            
           // commentSendView.frame.origin.y -= keyboardSize.height
            
            ////////
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustKeyboardDismissGesture(isKeyboardVisible: false)
        
            detailTableView.contentInset.bottom = 0
            //////// 키보드의 사이즈만큼 commentSendView의 y축을 아래로 이동시킴 ////////
            
            commentSendView.snp.remakeConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
            ////////
            self.view.layoutIfNeeded()
        
    }
    
    func adjustKeyboardDismissGesture(isKeyboardVisible: Bool) {
        if isKeyboardVisible {
            if keyboardDismissGesture == nil {
                keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground))
                view.addGestureRecognizer(keyboardDismissGesture!)
            }
        } else {
            if keyboardDismissGesture != nil {
                view.removeGestureRecognizer(keyboardDismissGesture!)
                keyboardDismissGesture = nil
            }
        }
    }
    
    @objc func tapBackground() {
        self.view.endEditing(true)
    }
}

//tapGesture
extension CommentVC : TapDelegate2, UIGestureRecognizerDelegate {
    
    func myTableDelegate(sender : UITapGestureRecognizer) {
        let touch = sender.location(in: detailTableView)
        if let indexPath = detailTableView.indexPathForRow(at: touch){
            let cell = self.detailTableView.cellForRow(at: indexPath) as! CommentCell
            let userId = cell.commentUserLbl.userId
            let myId = UserDefaults.standard.string(forKey: "userIdx") ?? "-1"
            if (myId == userId ){
                //내걸로
                if let myPageVC = Storyboard.shared().mypageStoryboard.instantiateViewController(withIdentifier:MyPageVC.reuseIdentifier) as? MyPageVC {
                    myPageVC.selectedUserId = userId
                    self.present(myPageVC, animated: true, completion: nil)
                }
            } else {
                //남의걸로
                if let otherUserPageVC = Storyboard.shared().subStoryboard.instantiateViewController(withIdentifier:OtherUserPageVC.reuseIdentifier) as? OtherUserPageVC {
                    otherUserPageVC.selectedUserId = userId
                    self.present(otherUserPageVC, animated: true, completion: nil)
                }
            }
            
        }
    }
    
}
//통신
extension CommentVC {
    func getCommentList(url : String){
        CommunityCommentService.shareInstance.getCommunity(url: url, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(let commentData):
                let commentData1 = commentData as! [CommunityCommentVOData]
                self.commentData = commentData1
                self.detailTableView.reloadData()
                
                break
            case .accessDenied :
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
                break
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
        
    }
    
    func temp(){
        let url = isCommunity ? UrlPath.BoardCommentList.getURL(gino(selectedBoard).description) : UrlPath.ContentCommentList.getURL(gino(selectedBoard).description)
        getCommentList(url : url)
    }
    
    //댓글달기
    func writeComment(url : String){
        
        let keyForIdx = isCommunity ? "board_id" : "contents_id"
        let params : [String : Any] = [
             keyForIdx : selectedBoard ?? 0,
            "content" : commentTxt.text ?? ""
        ]
        
        CommunityCommentWriteService.shareInstance.commentWrite(url: url, params: params, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(_):
                self.temp()
                
            case .accessDenied :
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
            case .networkFail :
                self.simpleAlert(title: "오류", message: "인터넷 연결상태를 확인해주세요")
            default :
                break
            }
        })
        
        
    }
    
    //댓글 삭제
    func deleteComment(url : String){
        CommentDeleteService.shareInstance.deleteComment(url: url, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(_):
                
                self.simpleAlert(title: "성공", message: "댓글 삭제 완료")
                
                self.temp()
                break
            case .accessDenied :
                self.simpleAlert(title: "오류", message: "삭제 권한이 없습니다")
                break
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
    }
    
    //하트 버튼 눌렀을 때
    func likeAction(url : String, boardIdx : Int, isLike : Int, cell : CommentCell, sender : myHeartBtn, likeCnt : Int){
        
        let params : [String : Any] = [
            "comment_id" : boardIdx
        ]
        CommunityLikeService.shareInstance.like(url: url, params: params, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .networkSuccess(_):
                sender.isSelected = true
                sender.isLike = 1
                self.commentData[sender.indexPath].islike = 1
                self.commentData[sender.indexPath].commentlikeCnt += 1
                
                
                break
            case .accessDenied :
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
    }
    
    //좋아요 취소
    func dislikeAction(url : String, cell : CommentCell, sender : myHeartBtn, likeCnt : Int){
        CommunityDislikeService.shareInstance.dislikeCommunity(url: url, completion: {  [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .networkSuccess(_):
                sender.isSelected = false
                sender.isLike = 0
                self.commentData[sender.indexPath].islike = 0
                self.commentData[sender.indexPath].commentlikeCnt -= 1
                
                
                break
            case .accessDenied :
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
    }
    
    //신고
    func reportAction(url : String, parmas : [String : Any]){
        ReportService.shareInstance.report(url: url, params: parmas, completion: {  [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .networkSuccess(_):
                 self.noticeSuccess("신고 완료", autoClear: true, autoClearTime: 1)
                break
            case .accessDenied :
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
    }
    
    
}

