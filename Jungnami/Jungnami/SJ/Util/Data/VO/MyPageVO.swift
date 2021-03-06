//
//  MyPageVO.swift
//  Jungnami
//
//  Created by 이지현 on 2018. 7. 12..
//

import Foundation

struct MyPageVO: Codable {
    let message: String
    let data: MyPageVOData
}

struct MyPageVOData: Codable {
    let mypageID, nickname : String
    let img: String?
    let scrapcnt, boardcnt, followingcnt, followercnt: Int
    let point : Int
    let votingcnt, pushcnt, isfollow: Int
    let scrap: [MyPageVODataScrap]
    let board: [MyPageVODataBoard]

    enum CodingKeys: String, CodingKey {
        case mypageID = "mypage_id"
        case nickname, scrapcnt, boardcnt, followingcnt, followercnt, votingcnt, pushcnt, scrap, board, isfollow
        case img
        case point
    }
}

struct MyPageVODataBoard: Codable {
    let bID: Int
    let uID, uNickname : String
    let uImg: String?
    let source: [MyPageVODataBoardSource]
    let bContent : String?
    let bImg: String?
    let bTime: String
    var likeCnt, commentCnt: Int
    var islike : Int
    
    enum CodingKeys: String, CodingKey {
        case bID = "b_id"
        case uID = "u_id"
        case uNickname = "u_nickname"
        case uImg = "u_img"
        case source
        case islike
        case bContent = "b_content"
        case bImg = "b_img"
        case bTime = "b_time"
        case likeCnt = "like_cnt"
        case commentCnt = "comment_cnt"
    }
}

struct MyPageVODataBoardSource: Codable {
    let uID, uNickname, bContent: String
    let uImg : String?
    let bImg, bTime: String
    
    enum CodingKeys: String, CodingKey {
        case uID = "u_id"
        case uNickname = "u_nickname"
        case uImg = "u_img"
        case bContent = "b_content"
        case bImg = "b_img"
        case bTime = "b_time"
    }
}

struct MyPageVODataScrap: Codable {
    let cID: Int
    let cTitle, thumbnail, text: String
    
    enum CodingKeys: String, CodingKey {
        case cID = "c_id"
        case cTitle = "c_title"
        case thumbnail, text
    }
}
