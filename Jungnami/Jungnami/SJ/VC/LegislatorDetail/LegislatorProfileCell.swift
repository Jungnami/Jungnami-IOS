//
//  LegislatorProfileCell.swift
//  Jungnami
//
//  Created by 이지현 on 2018. 7. 7..
//

import UIKit

class LegislatorProfileCell: UICollectionViewCell {
   
    @IBOutlet weak var medalImgView: UIImageView!
    @IBOutlet weak var bombImgView: UIImageView!
    @IBOutlet weak var legislatorProfileImgView: UIImageView!
    @IBOutlet weak var legislatorNameLbl: UILabel!
    @IBOutlet weak var legislatorLikeLbl: UILabel!
    @IBOutlet weak var legislatorDislikeLbl: UILabel!
    @IBOutlet weak var legislatorPartyLbl: UILabel!
    @IBOutlet weak var legislatorRegionLbl: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var voteBtn: UIButton!
    
    //self.contentView.viewWithTag(-1)?.removeFromSuperview()
    func configure(data: SampleLegislator) {
        legislatorProfileImgView.image = data.profile
        legislatorNameLbl.text = data.name
        legislatorPartyLbl.text = data.party.rawValue
        legislatorRegionLbl.text = data.region
        legislatorLikeLbl.text = "호감 \(data.likeCount)위"
        legislatorDislikeLbl.text = "비호감 \(data.dislikeCount)위"
        switch data.likeRank {
        case 1:
            medalImgView.image = #imageLiteral(resourceName: "legislator-detailpage_medal_gold")
        case 2:
            medalImgView.image = #imageLiteral(resourceName: "legislator-detailpage_medal_silver")
        case 3:
            medalImgView.image = #imageLiteral(resourceName: "legislator-detailpage_medal_bronze")
        default:
            medalImgView.deactivateAllConstraints()
            medalImgView.isHidden = true
        }
        switch data.dislikeRank {
        case 1:
            bombImgView.image = #imageLiteral(resourceName: "legislator-detailpage_red_bomb")
        case 2:
            bombImgView.image = #imageLiteral(resourceName: "legislator-detailpage_orange_bomb")
        case 3:
            bombImgView.image = #imageLiteral(resourceName: "legislator-detailpage_yellow_bomb")
        default:
           // bombImgView.deactivateAllConstraints()
            bombImgView.isHidden = true
        }
        switch data.party {
        case .blue:
             legislatorProfileImgView.makeImgBorder(width: 3, color: ColorChip.shared().partyBlue)
        case .red:
            legislatorProfileImgView.makeImgBorder(width: 3, color: ColorChip.shared().partyRed)
        case .orange:
            legislatorProfileImgView.makeImgBorder(width: 3, color: ColorChip.shared().partyOrange)
        case .mint:
            legislatorProfileImgView.makeImgBorder(width: 3, color: ColorChip.shared().partyMint)
        case .yellow:
            legislatorProfileImgView.makeImgBorder(width: 3, color: ColorChip.shared().partyYellow)
       
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        legislatorProfileImgView.makeImageRound()
        
    }
}

