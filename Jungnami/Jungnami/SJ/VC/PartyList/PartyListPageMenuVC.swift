//
//  PartyListPageMenuVC.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 3..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit
import SnapKit

class PartyListPageMenuVC: UIViewController, APIService {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var partyBtn: UIButton!
    @IBOutlet weak var partyLine: UIView!
    
    @IBOutlet weak var regionBtn: UIButton!
    @IBOutlet weak var regionLine: UIView!
    
    var keyboardDismissGesture: UITapGestureRecognizer?
    lazy var navSearchView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchGrayView : UIImageView = {
        let imgView = UIImageView()
        
        imgView.image = #imageLiteral(resourceName: "community_search_field")
        return imgView
    }()
    
    lazy var searchView : UIImageView = {
        let imgView = UIImageView()
        
        imgView.image = #imageLiteral(resourceName: "community_search")
        return imgView
    }()
    
    lazy var searchTxtField : UITextField = {
        let txtField = UITextField()
        txtField.placeholder = "찾고 싶은 국회의원을 검색해보세요"
        txtField.font = UIFont.systemFont(ofSize: 14.0)
        return txtField
    }()
    
    lazy var blackView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.4
        return view
    }()
    
    private lazy var partyListTVC: PartyListTVC = {

        let storyboard = Storyboard.shared().mainStoryboard
        
        var viewController = storyboard.instantiateViewController(withIdentifier: PartyListTVC.reuseIdentifier) as! PartyListTVC
       
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var regionVC: RegionVC = {
       
        let storyboard = Storyboard.shared().mainStoryboard
      
        var viewController = storyboard.instantiateViewController(withIdentifier: RegionVC.reuseIdentifier) as! RegionVC
      
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.view.backgroundColor = UIColor.white
        setKeyboardSetting()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTxtField.delegate = self
        setDefaultNav()
        blackView.isHidden = true
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        updateView(selected: 0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func searchLegislator(searchString : String){
        if let searchLegislatorResultTVC = self.storyboard?.instantiateViewController(withIdentifier:SearchLegislatorResultTVC.reuseIdentifier) as? SearchLegislatorResultTVC {
            self.navSearchView.endEditing(true)
            //searchLegislatorResultTVC = self.selectedCategory
           searchLegislatorResultTVC.searchString = searchString
        
            self.navigationController?.pushViewController(searchLegislatorResultTVC, animated: true)
        }
    }
    
  /*  func pushAction(selectedParty: PartyList) {
        print("aaa")
        if let partyListDetailPageMenuVC = self.storyboard?.instantiateViewController(withIdentifier:PartyListDetailPageMenuVC.reuseIdentifier) as? PartyListDetailPageMenuVC {
            partyListDetailPageMenuVC.selectedParty = selectedParty
            self.navigationController?.pushViewController(partyListDetailPageMenuVC, animated: true)
        }
    } */

    
    @IBAction func switchView(_ sender: UIButton) {
        updateView(selected: sender.tag)
    }
    
   
}

//네비게이션 기본바 커스텀
extension PartyListPageMenuVC {
    
    @objc func setDefaultNav(){
        //setupTitleNavImg
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "app_logo"))
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.snp.makeConstraints { (make) in
            make.height.equalTo(21)
            make.width.equalTo(52)
        }
        navigationItem.titleView = titleImageView
        navigationController?.navigationBar.isTranslucent = false
        
        //setupLeftNavItem
        let myPageBtn = UIButton(type: .system)
        myPageBtn.setImage(#imageLiteral(resourceName: "partylist_mypage").withRenderingMode(.alwaysOriginal), for: .normal)
        myPageBtn.addTarget(self, action:  #selector(PartyListPageMenuVC.toMyPage(_sender:)), for: .touchUpInside)
        myPageBtn.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myPageBtn)
        
        //setupRightNavItem
        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(#imageLiteral(resourceName: "partylist_search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        searchBtn.addTarget(self, action:  #selector(PartyListPageMenuVC.search(_sender:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBtn)

    }
    

   
}

//기본 네비게이션 바에서 오른쪽/왼쪽 아이템에 대한 행동
extension PartyListPageMenuVC {
    @objc public func toMyPage(_sender: UIButton) {
        let mypageVC = Storyboard.shared().mypageStoryboard.instantiateViewController(withIdentifier: MyPageVC.reuseIdentifier) as! MyPageVC
        let myId = UserDefaults.standard.string(forKey: "userIdx") ?? "-1"
        if (myId == "-1"){
            self.simpleAlertwithHandler(title: "오류", message: "로그인 해주세요", okHandler: { (_) in
                if let loginVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier:LoginVC.reuseIdentifier) as? LoginVC {
                    loginVC.entryPoint = 1
                    self.present(loginVC, animated: true, completion: nil)
                }
            })
            
        } else {
            mypageVC.selectedUserId = myId
            self.present(mypageVC, animated: true, completion: nil)
        }
    }
    
    @objc public func search(_sender: UIButton) {
        makeSearchBarView()
        self.navigationItem.leftBarButtonItem = nil
        
    }
}

//네비게이션 서치바 커스텀
extension PartyListPageMenuVC{
    func makeSearchBarView() {
        navSearchView.snp.makeConstraints { (make) in
            make.width.equalTo(311)
            make.height.equalTo(31)
            // make.leading.equalTo(self.)
        }
        navSearchView.addSubview(searchGrayView)
        navSearchView.addSubview(searchView)
        navSearchView.addSubview(searchTxtField)
        
        searchGrayView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(navSearchView)
        }
        
        searchView.snp.makeConstraints { (make) in
            make.leading.equalTo(searchGrayView).offset(10)
            make.width.height.equalTo(15)
            make.centerY.equalTo(searchGrayView)
        }
        
        searchTxtField.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(searchGrayView)
            make.leading.equalTo(searchView.snp.trailing).offset(8)
        }
        
        searchTxtField.delegate = self
        navigationItem.titleView = navSearchView
        navigationController?.navigationBar.isTranslucent = false
        
        //rightBarBtn
        let rightBarButton = customBarbuttonItem(title: "취소", red: 112, green: 112, blue: 112, fontSize: 14, selector: #selector(setDefaultNav))
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
}

//txtField Delegate (엔터버튼 클릭시)
extension PartyListPageMenuVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            simpleAlert(title: "오류", message: "검색어 입력")
            return false
        }
        
        if let myString = textField.text {
            let emptySpacesCount = myString.components(separatedBy: " ").count-1
            
            if emptySpacesCount == myString.count {
                simpleAlert(title: "오류", message: "검색어 입력")
                return false
            }
        }
        
        if let searchString_ = textField.text {
            searchLegislator(searchString : searchString_, url : UrlPath.SearchLegislator.getURL(searchString_))
        }
        
        
        return true
    }
}

//키보드 대응
extension PartyListPageMenuVC{
    func setKeyboardSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        blackView.isHidden = false
        adjustKeyboardDismissGesture(isKeyboardVisible: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        blackView.isHidden = true
        searchTxtField.text = ""
        // setDefaultNav()
        adjustKeyboardDismissGesture(isKeyboardVisible: false)
        
    }
    
    //화면 바깥 터치했을때 키보드 없어지는 코드
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
        self.navSearchView.endEditing(true)
    }

    
}

//메뉴바랑 그 안 컨테이너뷰
extension PartyListPageMenuVC{

    
    static func viewController() -> PartyListPageMenuVC {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PartyListPageMenuVC.reuseIdentifier) as! PartyListPageMenuVC
    }
    
    

    private func add(asChildViewController viewController: UIViewController) {
        
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    //----------------------------------------------------------------
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    //----------------------------------------------------------------
    
    private func updateView(selected : Int) {
        if selected == 0 {
            partyBtn.setTitleColor(ColorChip.shared().mainColor, for: .normal)
            partyLine.isHidden = false
            regionBtn.setTitleColor(#colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1), for: .normal)
            regionLine.isHidden = true
            remove(asChildViewController: regionVC)
            add(asChildViewController: partyListTVC)
        } else {
            regionBtn.setTitleColor(ColorChip.shared().mainColor, for: .normal)
            regionLine.isHidden = false
            partyBtn.setTitleColor(#colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1), for: .normal)
            partyLine.isHidden = true
            remove(asChildViewController: partyListTVC)
            add(asChildViewController: regionVC)
        }
    }
    
    
}

//통신
extension PartyListPageMenuVC {
    //의원검색
    func searchLegislator(searchString : String, url : String){
        LegislatorSearchService.shareInstance.searchLegislator(url: url) { [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .networkSuccess(let legislatorData):
                //dddddddd
                let legislatorSearchData = legislatorData as! [LegislatorSearchVOData]
                
                self.toSearchResultPage(searchString: searchString, legislatorSearchData: legislatorSearchData)
                break
            case .nullValue :
                self.simpleAlert(title: "오류", message: "검색 결과가 없습니다")
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 연결상태를 확인해주세요")
            default :
                break
            }
        }
    }
    
    func toSearchResultPage(searchString : String, legislatorSearchData : [LegislatorSearchVOData]){
        let mainStoryboard = Storyboard.shared().mainStoryboard
        if let searchLegislatorResultTVC = mainStoryboard.instantiateViewController(withIdentifier:SearchLegislatorResultTVC.reuseIdentifier) as? SearchLegislatorResultTVC {
            self.navSearchView.endEditing(true)
            searchLegislatorResultTVC.legislatorSearchData = legislatorSearchData
            searchLegislatorResultTVC.searchString = searchString
            searchLegislatorResultTVC.viewFrom = 0
            self.navigationController?.pushViewController(searchLegislatorResultTVC, animated: true)
        }
    }
}

