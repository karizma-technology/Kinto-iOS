//
//  KintoObject.swift
//  Kinto_Example
//
//  Created by user on 28/06/2017.
//  Copyright © 2017 Karizma LTD. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class KintoObject: NSObject {
    
    /**
     The collection name of the object.
     */
    
    var kintoCollectionName: String!
    
    /**
     The id of the object.
     */
    
    var objectId: String!
    
    
    open var data: NSMutableDictionary?
    private var dataSave: NSMutableDictionary?

    
    
    public override init(){
    }
    
    /**
     Initializes a new empty `KintoObject` instance with a collection name.
     @param newCollectionName A collection name
     */
    public init(collectionName newCollectionName: String) {
        //super.init()
        self.kintoCollectionName = newCollectionName
    }
    
    
    
    /**
     Creates a new `KintoObject` with a class name, initialized with data
     constructed from the specified set of objects and keys.
     @param CollectionName The object's collection.
     @param dictionary An `NSMutableDictionary` of keys and objects to set on the new `KintoObject`.
     */
    public convenience init(with dictionary: NSMutableDictionary, collectionName: String) {
        self.init(collectionName: collectionName)
        self.data = dictionary
        if let id = dictionary.object(forKey: "id") as? String{
            self.objectId = id
        }
    }
    
    /**
     Returns the value associated with a given key.
     */
    open func object(forKey key: String) -> Any?{
        return self[key]
    }
    
    /**
     Sets the object associated with a given key.
     */
    open func setObject(_ object: Any, forKey key: String){
        self[key] = object
    }
    
    /**
     Returns the value associated with a given key.
     This method enables usage of literal syntax on `KintoObject`.
     `let value = object["key"]`
     @param key The key for which to return the corresponding value.
     */
    open subscript(key: String) -> Any?{
        get {
            if data != nil {
                if self.data!.allKeys.contains(where: { (k) -> Bool in
                    return (k as! String) == key
                }) {
                    return self.data![key]
                }
            }
            return nil
        }
        set{
            if self.data == nil{
                self.data = NSMutableDictionary()
            }
            self.data![key] = newValue
        }
    }
    
    /**
     Saves the `KintoObject` asynchronously and executes the given callback block.
     The callback have the following argument signature: `^(BOOL succeeded, NSError *error)`.
     */
    open func saveInBackground(completionBlock: @escaping (KintoBooleanResultBlock)) {
        var parameters: Parameters = [:]
        self.dataSave = NSMutableDictionary(dictionary: self.data!)
        self.replaceKintoObjectByObjectId()
        if dataSave != nil {
            parameters = [
                "data":dataSave!
            ]
        }
        
        let url = KintoConfig.getCompleteUrl(collectionName: kintoCollectionName)
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: KintoConfig.auth()).responseJSON { (response) in
            print(response)
            switch response.result{
            case .failure(let error):
                completionBlock(false, error )
                break
            case .success(let value):
                let json = JSON(value)
                if  json["errno"].int != nil {
                    let errno = json["errno"].int!
                    if let error = getErrorFromCode(errno){
                        completionBlock(false, error)
                    }
                } else {
                    let json = JSON(value)
                    guard json["data"].dictionaryObject != nil else {
                        
                        completionBlock(false, KintoError.NoData)
                        return
                    }
                    self.objectId = json["data"].dictionaryObject?["id"] as! String
                    completionBlock(true, nil)
                }
            }
        }
    }
    
    /**
     Updates the `KintoObject` asynchronously and executes the given callback block.
     The callback have the following argument signature: `^(BOOL succeeded, NSError *error)`.
     */
    func updateObject(completionBlock: @escaping (KintoBooleanResultBlock)) {
        // create the request
        let url = KintoConfig.getCompleteUrlwithRecordId(collectionName: kintoCollectionName, recordId: self.objectId)
        var parameters: Parameters = [:]
        self.dataSave = NSMutableDictionary(dictionary: self.data!)
        self.replaceKintoObjectByObjectId()
        if dataSave != nil {
            parameters = [
                "data": dataSave!
            ]
        }
        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                completionBlock(false, error )
                break
            case .success(let value):
                let json = JSON(value)
                if  json["errno"].int != nil {
                    let errno = json["errno"].int!
                    if let error = getErrorFromCode(errno){
                        completionBlock(false, error)
                    }
                } else {
                    let json = JSON(value)
                    guard json["data"].dictionaryObject != nil else {
                        completionBlock(false, KintoError.NoData)
                        return
                    }
                    self.updatedAt = Date()
                    completionBlock(true, nil)
                }
            }
        }
    }
    
    /**
     Deletes the `KintoObject` asynchronously and executes the given callback block.
     The Callback have the following argument signature: `^(BOOL succeeded, NSError *error)`.
     */
    open func deleteInBackground(completionBlock: KintoBooleanResultBlock? = nil){
        
        let url = KintoConfig.getCompleteUrlwithRecordId(collectionName: kintoCollectionName, recordId: self.objectId)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: KintoConfig.auth()).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                completionBlock!(false, error )
                break
            case .success(let value):
                let json = JSON(value)
                if  json["errno"].int != nil {
                    let errno = json["errno"].int!
                    if let error = getErrorFromCode(errno){
                        completionBlock!(false, error)
                    }
                } else {
                    let json = JSON(response.value!)
                    guard json["data"].dictionaryObject != nil else {
                        completionBlock!(false, KintoError.NoData)
                        return
                    }
                    completionBlock!(true, nil)
                }
            }
        }
    }
    
    private func replaceKintoObjectByObjectId(){
        for (key,value) in self.dataSave! {
            if value is [KintoObject] {
                let objIds = (value as! [KintoObject]).flatMap { String(describing: $0.objectId!) }
                self.dataSave?[key] = objIds.joined(separator: ",")
            }
            if value is KintoObject {
                self.dataSave?[key] = (value as! KintoObject).objectId
            }
        }
    }
}
