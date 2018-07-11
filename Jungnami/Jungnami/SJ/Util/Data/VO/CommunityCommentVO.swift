//
//  CommunityCommentVO.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 11..
//

import Foundation
struct CommunityCommentVO: Codable {
    let message: String
    let data: [CommunityCommentVOData]
}

struct CommunityCommentVOData: Codable {
    let commentid: Int
    let timeset, content, userNick, userImg: String
    let recommentCnt, commentlikeCnt, islike: Int
    
    enum CodingKeys: String, CodingKey {
        case commentid, timeset, content
        case userNick = "user_nick"
        case userImg = "user_img"
        case recommentCnt, commentlikeCnt, islike
    }
}
