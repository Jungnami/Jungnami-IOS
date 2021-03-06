//
//  ContentsDetailVO.swift
//  Jungnami
//
//  Created by 이지현 on 2018. 7. 11..
//

import Foundation

struct ContentDetailVO: Codable {
    let message: String
    let data: ContentDetailVOData
}

struct ContentDetailVOData: Codable {
    let title, thumbnail, text, subtitle: String
    var type ,islike, isscrap : Int
    let imagearray: [ContentDetailVODataImgArr]
    let youtube: String
    var likeCnt, commentCnt: Int
}

struct ContentDetailVODataImgArr: Codable {
    let imgURL: String
    
    enum CodingKeys: String, CodingKey {
        case imgURL = "img_url"
    }
}
