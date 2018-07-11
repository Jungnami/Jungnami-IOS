//
//  CommentCell.swift
//  Jungnami
//
//  Created by 이지현 on 2018. 7. 3..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit
import Kingfisher

class CommentCell: UITableViewCell {

    //comment
    @IBOutlet weak var commentProfileImg: UIImageView!
    @IBOutlet weak var commentUserLbl: UILabel!
    @IBOutlet weak var commentContentLbl: UILabel!
    @IBOutlet weak var commentDateLbl: UILabel!
    @IBOutlet weak var commentLikeLbl: UILabel!
   
     @IBOutlet weak var recommentBtn: UIButton!
 
    @IBOutlet weak var commentBestImg: UIImageView!
    //댓글 좋아요 Btn
    @IBOutlet weak var commentLikeBtn: UIButton!
    //---------tapGesture--------
    var delegate : TapDelegate?
    var index = 0
    //----------------------------
    func configure(index : Int, data : CommunityCommentVOData){
      //  commentProfileImg.image = data.userImg
        if (gsno(data.userImg) == "0") {
            commentProfileImg.image = #imageLiteral(resourceName: "mypage_profile_girl")
        } else {
            if let url = URL(string: gsno(data.userImg)){
                self.commentProfileImg.kf.setImage(with: url)
            }
        }
        
        commentUserLbl.text = data.userNick
        commentContentLbl.text = data.content
        commentContentLbl.sizeToFit()
        commentDateLbl.text = data.timeset
        commentLikeLbl.text = "\(data.commentlikeCnt)"
        
        if index < 3 {
            commentBestImg.isHidden = true
        }
      //  index = 12 //나중에 유저 인덱스 등으로 고칠 수 있음
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentProfileImg.layer.masksToBounds = true
        commentProfileImg.layer.cornerRadius = commentProfileImg.layer.frame.width/2
        
        //------------tapGesture--------------------------
        commentProfileImg.isUserInteractionEnabled = true
        commentUserLbl.isUserInteractionEnabled = true
        
        let imgTapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentCell.imgTap(sender:)))
        let lblTapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentCell.lblTap(sender:)))
        self.commentUserLbl.addGestureRecognizer(lblTapGesture)
        self.commentProfileImg.addGestureRecognizer(imgTapGesture)
    }

    @objc func imgTap(sender: UITapGestureRecognizer) {
        delegate?.myTableDelegate(index : index)
    }
    @objc func lblTap(sender: UITapGestureRecognizer) {
        delegate?.myTableDelegate(index : index)
    }
    //-----------------------------------------------
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}