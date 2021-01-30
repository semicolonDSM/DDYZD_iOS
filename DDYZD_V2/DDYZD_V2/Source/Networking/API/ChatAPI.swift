//
//  ChatAPI.swift
//  DDYZD_V2
//
//  Created by 김수완 on 2021/01/24.
//

import Foundation

import Alamofire
import RxSwift

class ChatAPI {
    let httpClient = HTTPClient()
    
    func getChatList() -> Observable<([ChatRoom]? ,StatusCodes)> {
        httpClient.get(.clubList, param: nil)
            .map{ response, data -> ([ChatRoom]?, StatusCodes) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode([ChatRoom].self, from: data) else { return (nil, .fault)}
                    return(data, .success)
                default:
                    return (nil, .fault)
                }
            }
    }
}
