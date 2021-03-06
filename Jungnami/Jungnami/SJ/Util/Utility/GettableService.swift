//
//  GettableService.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 9..
//

import Foundation
import Alamofire
import SwiftyJSON

protocol GettableService {
    associatedtype NetworkData : Codable
    typealias networkResult = (resCode : Int, resResult : NetworkData)
    func get(_ URL:String, completion : @escaping (Result<networkResult>)->Void)
}

extension GettableService {
    
    func gino(_ value : Int?) -> Int {
        return value ?? 0
    }
    
    func get(_ URL:String, completion : @escaping (Result<networkResult>)->Void){
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        let userToken = UserDefaults.standard.string(forKey: "userToken") ?? "-1"
        var headers: HTTPHeaders?
        
        if userToken != "-1" {
            headers = [
                "authorization" : userToken
            ]
        }

        Alamofire.request(encodedUrl, method: .get, parameters: nil, headers: headers).responseData {(res) in
            print("encodedURK")
            print(encodedUrl)
            switch res.result {
                
            case .success :
                if let value = res.result.value {
                    print("networking Here!")
                    print(encodedUrl)
                    print(JSON(value))
                    
                    let decoder = JSONDecoder()
                    do {
                        let resCode = self.gino(res.response?.statusCode)
                        let data = try decoder.decode(NetworkData.self, from: value)
                        
                        let result : networkResult = (resCode, data)
                        completion(.success(result))
                        
                    }catch{
                        completion(Result.error("에러"))
                    }
                }
                break
            case .failure(let err) :
                print("network~~ error")
                print(err)
                completion(Result.failure(err as! Error))
                break
            }
            
        }
    }
}
