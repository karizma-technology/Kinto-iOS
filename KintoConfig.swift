//
//  KintoConfig.swift
//  Challengers
//
//  Created by Karizma LTD on 03/07/2017.
//  Copyright © 2017 Karizma LTD. All rights reserved.
//

import Foundation
import Alamofire

class KintoConfig {
    
    static var url: String!
    static var bucketName: String!
    static var username: String!
    static var password: String!
    
    
    
    init(url:String, bucketName: String, username:String, password: String) {
        KintoConfig.url = url
        KintoConfig.bucketName = bucketName
        KintoConfig.username = username
        KintoConfig.password = password
    }
    
    static func appendBucketNameToUrl(bucketName: String) -> String{
        return self.url + "/buckets/\(self.bucketName!)"
    }
    
    static func getCollectionURL(bucketName: String) -> String {
        return self.url + "/buckets/\(self.bucketName!)/collections"
    }
    
    static func appendCollectionNameToUrl(collectionName: String) -> String{
        return self.url + "/buckets/\(self.bucketName!)/collections/\(collectionName)"
    }
    
    static func getCompleteUrl(collectionName: String) -> String {
        return self.url + "/buckets/\(self.bucketName!)/collections/\(collectionName)/records"
    }
    
    static func getCompleteUrlwithRecordId(collectionName: String, recordId: String) -> String{
        return self.url + "/buckets/\(self.bucketName!)/collections/\(collectionName)/records/\(recordId)"
    }
    
    static func auth() -> HTTPHeaders {
        var header: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            header[authorizationHeader.key] = authorizationHeader.value
        }
        return header
    }

    
}
