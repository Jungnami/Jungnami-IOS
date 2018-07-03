//
//  CommunityTVC.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 1..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit

class CommunityTVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var badgeBackground: UIImageView!
    @IBOutlet weak var alertBadge: UILabel!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func myProfileBtn(_ sender: Any) {
       
    }
    
    @IBAction func alarmBtn(_ sender: Any) {

        
    }
    
    var sampleData : [Sample] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTxtField.delegate = self
        self.view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
        //////////////////////뷰 보기 위한 샘플 데이터//////////////////////////
         addChildView(containerView: containerView, asChildViewController: writeVC)
        let a = Sample(profileUrl: #imageLiteral(resourceName: "dabi"), name: "다비다비", time: "1시간 전", content: "다비 최고야,, 형윤 최고야,, 디자인 세상에서 제일 예뻐요 선생님들,, ", like: 3, comment: 5, contentImg: nil, heart: true, scrap: false)
         let b = Sample(profileUrl: #imageLiteral(resourceName: "community_character"), name: "제리", time: "4시간 전", content: "픽미픽미픽미업", like: 73, comment: 6020, contentImg: #imageLiteral(resourceName: "inni"), heart: false, scrap: true)
        
        sampleData.append(a)
        sampleData.append(b)
        ////////////////////////////////////////////////////
        
    }
    

    //TODO
    //1. 나중에 유저가 로그인 되어있냐 안되어 있냐에 따라서 addChildView, removeChildView 함수 이용해서 보이는 뷰 바뀌게 하기
    //2. 만약 알람 없으면 뱃지 안보이게
    
    private lazy var needLoginVC: NeedLoginVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: NeedLoginVC.reuseIdentifier) as! NeedLoginVC
        return viewController
    }()
    
    private lazy var writeVC: WriteVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: WriteVC.reuseIdentifier) as! WriteVC
        return viewController
    }()

  

}

//tableView deleagete, datasource
extension CommunityTVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sampleData.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommunityTVCell.reuseIdentifier) as! CommunityTVCell
        
        cell.configure(data: sampleData[indexPath.row])
        return cell
        
    }
    
}

//키보드 엔터 버튼 눌렀을 때
extension CommunityTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //TODO - 확인 누르면 데이터 로드하는 통신 코드
        return true
    }
}




