//
//  OtherUserHeaderView.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 8. 9..
//


import UIKit

class OtherUserHeaderView: UIView {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileuserNameLbl: UILabel!
    @IBOutlet weak var profileScrapNumLbl: UILabel!
    @IBOutlet weak var profileMyfeedNumLbl: UILabel!
    @IBOutlet weak var profileFollowingNumLbl: UILabel!
    @IBOutlet weak var profileFollowerNumLbl: UILabel!
    

    @IBOutlet weak var dismissBtn: UIButton!

    
    class func instanceFromNib() -> OtherUserHeaderView {
        
        
        return UINib(nibName: "OtherUserHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OtherUserHeaderView
    }
    
}

