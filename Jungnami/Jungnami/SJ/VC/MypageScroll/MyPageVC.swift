//
//  LTAdvancedManagerDemo.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 8. 6..
//

import UIKit
import LTScrollView

class MyPageVC: UIViewController, APIService {
    
    
    let myScrapVC = MyPageScrapVC()
    let myFeedVC = MyPageFeedVC()
    var selectedUserId : String?
    var imageData : Data? {
        didSet {
            if imageData != nil {
                editProfileAction(url: UrlPath.EditProfile.getURL())
            }
        }
        
    }
    
    var myBoardData : [MyPageVODataBoard]  = [] {
        didSet {
            myFeedVC.myBoardData = myBoardData
        }
    }
    var myScrapData : [MyPageVODataScrap]  = [] {
        didSet {
            myScrapVC.myScrapData = myScrapData
        }
    }
    private let glt_iphoneX = (UIScreen.main.bounds.height == 812.0)
    private lazy var viewControllers: [UIViewController] = {
        let tableView =  myFeedVC.tableView
        tableView.register(UINib.init(nibName: MypageFeedTVCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MypageFeedTVCell.reuseIdentifier)
        
        tableView.register(UINib.init(nibName: MypageFeedScrapTVCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MypageFeedScrapTVCell.reuseIdentifier)
        
        tableView.register(UINib.init(nibName: MypageNoImageFeedTVcell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MypageNoImageFeedTVcell.reuseIdentifier)
        
        tableView.register(UINib.init(nibName: MypageNoImageFeedScrapTVCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MypageNoImageFeedScrapTVCell.reuseIdentifier)
        
        
        return [myScrapVC, myFeedVC]
    }()
    
    private lazy var titles: [String] = {
        return ["스크랩", "피드"]
    }()
    
    //헤더 뷰 생성 후, 그 안에 프로퍼티들 설정
    private lazy var headerView : MypageHeaderView = {
        let headerView = MypageHeaderView.instanceFromNib()
        headerView.dismissBtn.addTarget(self, action: #selector(self.dismiss(_:)), for: .touchUpInside)
        headerView.alarmBtn.addTarget(self, action: #selector(self.toAlarmVC(_:)), for: .touchUpInside)
        //make label button
        let tapFollow = UITapGestureRecognizer(target: self, action: #selector(MyPageVC.tapFollowLbl(_:)))
        headerView.profileFollowingNumLbl.isUserInteractionEnabled = true
        headerView.profileFollowingNumLbl.addGestureRecognizer(tapFollow)
        
        let tapFollower = UITapGestureRecognizer(target: self, action: #selector(MyPageVC.tapFollowerLbl(_:)))
        headerView.profileFollowerNumLbl.isUserInteractionEnabled = true
        headerView.profileFollowerNumLbl.addGestureRecognizer(tapFollower)
        
        let profileImgTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.profileImgTap(sender:)))
        headerView.profileImgView.isUserInteractionEnabled = true
        headerView.profileImgView.addGestureRecognizer(profileImgTapGesture)
        
        //false -> true 로 바꾸기
        let tapAction1 = UITapGestureRecognizer(target: self, action: #selector(self.actionTapped(_:)))
        let tapAction2 = UITapGestureRecognizer(target: self, action: #selector(self.actionTapped(_:)))
        headerView.profileCoinCountLbl?.isUserInteractionEnabled = false
        headerView.profileCoinCountLbl?.addGestureRecognizer(tapAction1)
        headerView.profileVoteCountLbl?.isUserInteractionEnabled = false
        headerView.profileVoteCountLbl?.addGestureRecognizer(tapAction2)
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 314)
        return headerView
    }()
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.titleViewBgColor = .white
        layout.titleColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        layout.titleSelectColor = ColorChip.shared().mainColor
        layout.sliderHeight = 41.0
        layout.bottomLineHeight = 0
        
        layout.bottomLineHeight = 3
        layout.sliderWidth = 84
        layout.bottomLineColor = ColorChip.shared().mainColor
        layout.isAverage = true
        layout.isNeedScale = false
        
        return layout
    }()
    
    
    private lazy var advancedManager: LTAdvancedManager = {
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let Y: CGFloat = statusBarH
        let H: CGFloat = glt_iphoneX ? (view.bounds.height - Y - 34) : view.bounds.height - Y
        let advancedManager = LTAdvancedManager(frame: CGRect(x: 0, y: Y, width: view.bounds.width, height: H), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
            guard let strongSelf = self else { return UIView() }
            return headerView
        })
        
        return advancedManager
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedUserId_ = selectedUserId {
            getMyPage(url: UrlPath.Mypage.getURL(selectedUserId_))
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
    }
    
    deinit {
        print("LTAdvancedManagerDemo < --> deinit")
    }
}

//LTAdvancedScrollViewDelegate
extension MyPageVC {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
        advancedManager.advancedDidSelectIndexHandle = {
            print("현재 인덱스는 -> \($0)")
        }
        
    }
}

//헤더 뷰에 대한것 설정
extension MyPageVC {
    
    func setHeaderInfo(myPageData : MyPageVOData){
        
        guard let headerView_ = headerView as? MypageHeaderView else {return}
        
        if (self.gsno(myPageData.img) == "") {
            headerView_.profileImgView.image = #imageLiteral(resourceName: "mypage_profile_girl")
            
        } else {
            if let url = URL(string: self.gsno(myPageData.img)){
                headerView_.profileImgView.kf.setImage(with: url)
            }
        }
        
        
        headerView_.profileImgView.makeImageRound()
        headerView_.profileuserNameLbl.text = myPageData.nickname
        headerView_.profileScrapNumLbl.text = "\(myPageData.scrapcnt)"
        headerView_.profileMyfeedNumLbl.text = "\(myPageData.boardcnt)"
        headerView_.profileFollowingNumLbl.text = "\(myPageData.followingcnt)"
        headerView_.profileFollowerNumLbl.text = "\(myPageData.followercnt)"
        headerView_.profileCoinCountLbl.text = "\(myPageData.point)개"
        headerView_.profileVoteCountLbl.text = "\(myPageData.votingcnt)개"
        
        //alarm
        let alarmCount = myPageData.pushcnt
        if alarmCount == 0 {
            headerView_.alarmCountLbl.isHidden = true
            headerView_.alarmBG.isHidden = true
        } else {
            headerView_.alarmCountLbl.isHidden = false
            headerView_.alarmBG.isHidden = false
            if alarmCount > 99 {
                headerView_.alarmCountLbl.text = "99+"
            } else {
                headerView_.alarmCountLbl.text = "\(alarmCount)"
            }
            
        } //알람 설정
        
    }//setHeaderInfo
    
    
    @objc func profileImgTap(sender: UITapGestureRecognizer) {
        checkAlbumPermission()
    }
    
    
    
}

//앨범 열기 위함
extension MyPageVC : UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //크롭한 이미지
        if let editedImage: UIImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageData = UIImageJPEGRepresentation(editedImage, 1.0)
        } else if let originalImage: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageData = UIImageJPEGRepresentation(originalImage, 1.0)
        }
        
        self.dismiss(animated: true)
    }
}

//각종 버튼/레이블 클릭했을때 관한 이벤트들
extension MyPageVC {
    @objc func dismiss(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //followLbl 터치했을 때 화면 올리기
    @objc func tapFollowLbl(_ sender: UITapGestureRecognizer) {
        if let followListVC = Storyboard.shared().subStoryboard.instantiateViewController(withIdentifier:FollowListVC.reuseIdentifier) as? FollowListVC {
            followListVC.selectedUserId = selectedUserId
            followListVC.entryPoint = 0
            followListVC.navTitle = "팔로잉"
            self.pleaseWait()
            self.present(followListVC, animated: true, completion: nil)
        }
    }
    //followerLbl 터치했을 때 화면 올리기
    @objc func tapFollowerLbl(_ sender: UITapGestureRecognizer) {
        if let followListVC = Storyboard.shared().subStoryboard.instantiateViewController(withIdentifier:FollowListVC.reuseIdentifier) as? FollowListVC {
            followListVC.selectedUserId = selectedUserId
            followListVC.entryPoint = 1
            followListVC.navTitle = "팔로워"
            self.pleaseWait()
            self.present(followListVC, animated: true, completion: nil)
        }
    }
    
    //알림페이지로
    @objc func toAlarmVC(_ sender : UIButton){
        if let noticeVC = Storyboard.shared().subStoryboard.instantiateViewController(withIdentifier:NoticeVC.reuseIdentifier) as? NoticeVC {
            
            let myId = UserDefaults.standard.string(forKey: "userIdx") ?? "-1"
            if (myId == "-1"){
                self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                    if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                        loginVC.entryPoint = 1
                        self.present(loginVC, animated: true, completion: nil)
                    }
                })
                
            } else {
                self.present(noticeVC, animated : true)
            }
            
        }
    } //알림페이지
    
    //코인 충전으로
    @objc func actionTapped(_ sender: UITapGestureRecognizer) {
        if let chargeVC = Storyboard.shared().subStoryboard.instantiateViewController(withIdentifier:ChargeVC.reuseIdentifier) as? ChargeVC {
            self.present(chargeVC, animated: true, completion: nil)
        }
    }
}

//통신

extension MyPageVC {
    func getMyPage(url : String) {
        MypageService.shareInstance.getUserPage(url: url, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .networkSuccess(let myPageData):
                
                let myPageData = myPageData as! MyPageVOData
                self.setHeaderInfo(myPageData: myPageData)
                
                self.myBoardData = myPageData.board
                self.myScrapData = myPageData.scrap
                
                break
            case .nullValue :
                self.simpleAlert(title: "오류", message: "값 없음")
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
            
        })
    }
    
    //사진 변경
    func editProfileAction(url : String){
        
        let params : [String : Any] = [
            "nickname" : self.gsno(self.headerView.profileuserNameLbl.text)
        ]
        
        var images : [String : Data]?
        if let image = imageData {
            images = [
                "img_url" : image
            ]
        }
        CommunityWriteCompleteService.shareInstance.registerBoard(url: url, params: params, image: images, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(_):
                self.headerView.profileImgView.image = UIImage(data: self.imageData!)
                self.noticeSuccess("사진 변경 완료", autoClear: true, autoClearTime: 1)
            case .networkFail :
                self.simpleAlert(title: "오류", message: "인터넷 연결상태를 확인해주세요")
            default :
                break
            }
        })
    }
}

