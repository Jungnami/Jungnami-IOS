//
//  CommunityCommentDislikeService.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 11..
//

import Foundation
import Alamofire
import SwiftyJSON

struct CommunityDislikeService: PostableService {
    
    typealias NetworkData = MessageVO
    static let shareInstance = CommunityDislikeService()
    func dislikeCommunity(url : String, completion : @escaping (NetworkResult<Any>) -> Void){
        delete(url, params: [:]) { (result) in
            switch result {
            case .success(let networkResult):
                switch networkResult.resCode{
                case 200 :
                    completion(.networkSuccess(""))
                case 401 :
                    completion(.accessDenied)
                case 500 :
                    completion(.serverErr)
                default :
                    print("rescode is \(networkResult.resCode)")
                    break
                }
            case .error(let errMsg) :
                print(errMsg)
                break
            case .failure(_) :
                completion(.networkFail)
            }
        }
        
    }
}

