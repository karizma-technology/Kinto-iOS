//
//  KintoAPIExtension.swift
//  Kinto_Example
//
//  Created by Karizma LTD on 16/06/2017.
//  Copyright © 2017 Karizma LTD. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class KintoQuery {
    
    private var includedKeys: [String] = []
    private var collectionName: String?
    private var parameters: Parameters? = [:]
    open var limit:Int? = nil
    open var nextPage: String!
    
    /**
     Initializes a new empty `KinotQuery` instance with a collection name.
     */
    init(collectionName: String) {
        self.collectionName = collectionName
    }
    
    /**
     Filters
     */
    
    open func whereKey(recordName: String, equalTo: Any) {
        self.parameters?[recordName] = equalTo
    }
    
    open func whereKey(recordName:String, notEqualTo: Any) {
        self.parameters?["not_\(recordName)"] = notEqualTo
    }
    
    open func whereKey(recordName:String, lessThan: Any) {
        self.parameters?["lt_\(recordName)"] = lessThan
    }
    
    open func whereKey(recordName: String, greaterThan: Any){
        self.parameters?["gt_\(recordName)"] = greaterThan
        
    }
    
    open func whereKey(recordName: String, lessThanOrEqual:Any) {
        self.parameters?["max_\(recordName)"] = lessThanOrEqual
    }
    
    open func whereKey(recordName: String, greaterThanOrEqual:Any) {
        self.parameters?["min_\(recordName)"] = greaterThanOrEqual
    }
    
    open func whereKey(recordName: String, containedIn:[Any]) {
        self.parameters?["in_\(recordName)"] = containedIn
    }
    
    open func whereKey(recordName: String, notContainedIn:[Any]) {
        self.parameters?["exclude_\(recordName)"] = notContainedIn
    }
    
    open func whereKey(recordName: String, contains:String) {
        self.parameters?["like_\(recordName)"] = contains
    }
    
    open func whereKey(recordName: String, hasPrefix:String) {
        self.parameters?["like_\(recordName)"] = "\(hasPrefix)*"
    }
    
    open func whereKey(recordName: String, hasSuffix:String) {
        self.parameters?["like_\(recordName)"] = "*\(hasSuffix)"
    }
    
    open func whereKeyExists(recordName:String) {
        self.parameters?["has_\(recordName)"] = true
    }
    
    open func whereKeyDoesNotExist(recordName:String) {
        self.parameters?["has_\(recordName)"] = false
    }
    
    open func order(byAscending: String){
        self.parameters?["_sort"] = "field,\(byAscending)"
    }
    
    open func order(byDescending: String){
        self.parameters?["_sort"] = "field,-\(byDescending)"
    }
    
    
///--------------------------------------
//  MARK: Find Objects
///--------------------------------------

    open func findObjectsInBackground(completionBlock: @escaping (KintoQueryArrayResultBlock)) {
        if limit != nil {
            self.parameters = ["_limit": self.limit!]
        }
        let url = KintoConfig.getCompleteUrl(collectionName:self.collectionName!)
        Alamofire.request(url, method: .get, parameters: self.parameters, encoding: CustomGetEncoding(), headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                if error.localizedDescription == "The Internet connection appears to be offline."{
                    print("no Internet")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        print("Rexecuted after 5 secondes ")
                        self.findObjectsInBackground(completionBlock: completionBlock)
                    })
                }
                completionBlock(nil, error)
                break;
            case .success(let value):
                let json = JSON(value)
                guard json["data"].array != nil else {
                    completionBlock(nil, KintoError.NoData)
                    return
                }
                
                guard json["data"].array?.count != 0 else {
                    completionBlock([], nil)
                    return
                }
                
                if response.response?.allHeaderFields["Next-Page"] != nil {
                    self.nextPage = response.response?.allHeaderFields["Next-Page"] as! String
                    
                    if self.nextPage.contains("127.0.0.1") {
                        self.nextPage = self.nextPage.replacingOccurrences(of: "http://127.0.0.1:8888/v1", with: KintoConfig.url)
                    }
                }
                
                var results = [KintoObject]()
                var index = 0
                for res in json["data"].array! {
                    var res = res
                    if self.includedKeys.count > 0 {
                        var indexInc = 0
                        for includedKey in self.includedKeys {
                            if let includeKeyRes =  res.dictionaryObject![includedKey.lowercased()] as? String {
                                if includeKeyRes.characters.count > 0{
                                    let query = KintoQuery(collectionName: includedKey)
                                    query.whereKey(recordName: "id", containedIn: includeKeyRes.components(separatedBy: ","))
                                    query.getObjects(completionBlock: { (objs, error) in
                                        if error == nil {
                                            res.dictionaryObject![includedKey] = objs
                                            indexInc += 1
                                            if indexInc == self.includedKeys.count {
                                                let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                                results.append(kObject)
                                                index += 1
                                                if index == (json["data"].array?.count)!
                                                {
                                                    completionBlock(results , nil)
                                                }
                                            }
                                        }else if let error = error {
                                            completionBlock(nil, error)
                                        }
                                    })
                                    
                                }else{
                                    indexInc += 1
                                    if indexInc == self.includedKeys.count {
                                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                        results.append(kObject)
                                        index += 1
                                        if index == (json["data"].array?.count)!
                                        {
                                            completionBlock(results , nil)
                                        }
                                    }
                                }
                            }else{
                                indexInc += 1
                                if indexInc == self.includedKeys.count {
                                    let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                    results.append(kObject)
                                    index += 1
                                    if index == (json["data"].array?.count)!
                                    {
                                        completionBlock(results , nil)
                                    }
                                }
                            }
                            
                        }
                    }else{
                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                        
                        results.append(kObject)
                        index += 1
                        if index == (json["data"].array?.count)!
                        {
                            completionBlock(results , nil)
                        }
                    }
                }
                
            }
        }
    }
    
///--------------------------------------
//  MARK: Get Objects
///--------------------------------------
    open func getFirstObject(completionBlock: @escaping KintoQueryObjectResultBlock){
        self.limit = 1
        self.findObjectsInBackground { (result, error) in
            if error == nil, (result?.count)! > 0 {
                let object = result?[0]
                completionBlock(object, nil)
            } else {
                completionBlock(nil, error)
            }
        }
    }
    
   private func getObjects(completionBlock: @escaping (KintoQueryArrayResultBlock)) {
        if limit != nil {
            self.parameters = ["_limit": self.limit!]
        }
        
        let url = KintoConfig.getCompleteUrl(collectionName:self.collectionName!)
        Alamofire.request(url, method: .get, parameters: self.parameters, encoding: CustomGetEncoding(), headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                completionBlock(nil, error)
                break;
            case .success(let value):
                let json = JSON(value)
                guard json["data"].array != nil else {
                    completionBlock(nil, KintoError.NoData)
                    return
                }
                
                guard json["data"].array?.count != 0 else {
                    completionBlock([], KintoError.NoData)
                    return
                    
                }
                
                var results = [KintoObject]()
                var index = 0
                for res in json["data"].array! {
                    let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                    results.append(kObject)
                    index += 1
                    if index == (json["data"].array?.count)!
                    {
                        completionBlock(results , nil)
                    }
                }
            }
        }
    }
    
    open func getObjectWithId(_ kintoId: String, completionBlock: @escaping (KintoQueryObjectResultBlock)) {
        // create the request
        let url = KintoConfig.getCompleteUrlwithRecordId(collectionName: self.collectionName!, recordId: kintoId)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: KintoConfig.auth()).responseJSON { (response) in
            //response.
            
            switch response.result{
                
            case .failure(let error):
                completionBlock(nil, error )
                break
            case .success(let value):
                let json = JSON(value)
                
                if  json["errno"].int != nil {
                    let errno = json["errno"].int!
                    if let error = getErrorFromCode(errno){
                        completionBlock(nil, error)
                    }
                    
                } else {
                    
                    let json = JSON(response.value!)
                    
                    guard json["data"].dictionaryObject != nil else {
                        completionBlock(nil, KintoError.NoData)
                        return
                    }
                    
                    var object = json["data"].dictionaryObject!
                    if self.includedKeys.count > 0 {
                        var indexInc = 0
                        for includedKey in self.includedKeys{
                            if let includeKeyRes =  object[includedKey.lowercased()] as? String {
                                if includeKeyRes.characters.count > 0{
                                    let query = KintoQuery(collectionName: includedKey)
                                    query.whereKey(recordName: "id", containedIn: includeKeyRes.components(separatedBy: ","))
                                    query.getObjects(completionBlock: { (objects, error) in
                                        if error == nil {
                                            object[includedKey] = objects
                                            let kObject = KintoObject(with: NSMutableDictionary(dictionary: object), collectionName: self.collectionName!)
                                            indexInc += 1
                                            if indexInc == self.includedKeys.count{
                                                completionBlock(kObject, nil)
                                            }
                                        }
                                    })
                                }else{
                                    indexInc += 1
                                    if indexInc == self.includedKeys.count {
                                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: object), collectionName: self.collectionName!)
                                        completionBlock(kObject, nil)
                                    }
                                }
                            }else{
                                indexInc += 1
                                if indexInc == self.includedKeys.count {
                                    let kObject = KintoObject(with: NSMutableDictionary(dictionary: object), collectionName: self.collectionName!)
                                    completionBlock(kObject, nil)
                                }
                            }
                        }
                    } else{
                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: object) , collectionName: self.collectionName!)
                        completionBlock(kObject , nil)
                    }
                }
            }
        }
    }
    
    
///--------------------------------------
//  MARK: Count Objects
///--------------------------------------
    
    
    open func countInBackground(completionBlock: KintoIntegerResultBlock? = nil){
        let url = KintoConfig.getCompleteUrl(collectionName: self.collectionName!)
        Alamofire.request(url, method: .get, parameters: self.parameters, encoding: URLEncoding.default, headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                completionBlock!(nil,error)
            case .success(let value):
                let json = JSON(value)
                if json["erno"].int != nil {
                    let erno = json["erno"].int
                    if let error = getErrorFromCode(erno!){
                        completionBlock!(nil,error)
                    }
                } else {
                    let json = JSON(value)
                    guard json["data"].array != nil else {
                        completionBlock!(nil, KintoError.NoData)
                        return
                    }
                    let count = Int32(response.response?.allHeaderFields["Total-Records"] as! String)
                    completionBlock!(count, nil)
                }
            }
        }
    }
    
///--------------------------------------
//  MARK: Get Next Page Objects
///--------------------------------------
    
    
    open func getNextPage(nextPageUrl: String, completionBlock: @escaping (KintoQueryArrayResultBlock)){
        
        Alamofire.request(nextPageUrl, method: .get, parameters: self.parameters, encoding: CustomGetEncoding(), headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                if error.localizedDescription == "The Internet connection appears to be offline."{
                    print("no Internet")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        print("Rexecuted after 5 secondes ")
                        self.getNextPage(nextPageUrl: self.nextPage, completionBlock: completionBlock)
                    })
                }
                completionBlock(nil, error)
                break;
            case .success(let value):
                let json = JSON(value)
                guard json["data"].array != nil else {
                    completionBlock(nil, KintoError.NoData)
                    return
                }
                
                guard json["data"].array?.count != 0 else {
                    completionBlock([], nil)
                    return
                }
                
                if response.response?.allHeaderFields["Next-Page"] != nil {
                    self.nextPage = response.response?.allHeaderFields["Next-Page"] as! String
                    
                    if self.nextPage.contains("127.0.0.1") {
                        self.nextPage = self.nextPage.replacingOccurrences(of: "http://127.0.0.1:8888/v1", with: KintoConfig.url)
                    }
                }
                
                var results = [KintoObject]()
                var index = 0
                for res in json["data"].array! {
                    var res = res
                    if self.includedKeys.count > 0 {
                        var indexInc = 0
                        for includedKey in self.includedKeys {
                            if let includeKeyRes =  res.dictionaryObject![includedKey.lowercased()] as? String {
                                if includeKeyRes.characters.count > 0{
                                    let query = KintoQuery(collectionName: includedKey)
                                    query.whereKey(recordName: "id", containedIn: includeKeyRes.components(separatedBy: ","))
                                    query.getObjects(completionBlock: { (objs, error) in
                                        if error == nil {
                                            res.dictionaryObject![includedKey] = objs
                                            indexInc += 1
                                            if indexInc == self.includedKeys.count {
                                                let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                                results.append(kObject)
                                                index += 1
                                                if index == (json["data"].array?.count)!
                                                {
                                                    completionBlock(results , nil)
                                                }
                                            }
                                        }else if let error = error {
                                            completionBlock(nil, error)
                                        }
                                    })
                                    
                                }else{
                                    indexInc += 1
                                    if indexInc == self.includedKeys.count {
                                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                        results.append(kObject)
                                        index += 1
                                        if index == (json["data"].array?.count)!
                                        {
                                            completionBlock(results , nil)
                                        }
                                    }
                                }
                            }else{
                                indexInc += 1
                                if indexInc == self.includedKeys.count {
                                    let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                                    results.append(kObject)
                                    index += 1
                                    if index == (json["data"].array?.count)!
                                    {
                                        completionBlock(results , nil)
                                    }
                                }
                            }
                            
                        }
                    }else{
                        let kObject = KintoObject(with: NSMutableDictionary(dictionary: res.dictionaryObject!), collectionName: self.collectionName!)
                        
                        results.append(kObject)
                        index += 1
                        if index == (json["data"].array?.count)!
                        {
                            completionBlock(results , nil)
                        }
                    }
                }
            }
        }
    }
    
    open func includeKey(recordName: String){
        self.includedKeys.append(recordName)
    }
    
    private struct CustomGetEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%2A", with: "*"))
            
            return request
        }
    }
}
