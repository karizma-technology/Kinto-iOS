//
//  KintoError.swift
//  Kinto_Example
//
//  Created by user on 16/06/2017.
//  Copyright © 2017 Karizma LTD. All rights reserved.
//


import Foundation

enum KintoError: Error{
    case NoData
    case missingAuthorizationToken
    case invalidAuthorizationToken
    case requestBodyWasNotValidJSON
    case invalidRequestParameter
    case missingRequestParameter
    case invalidPostedData
    case invalidTokenId
    case missingTokenId
    case contentLengthHeaderWasNotProvided
    case requestBodyTooLarge
    case resourceWasModifiedMeanwhile
    case methodNotAllowedOnThisEndPoint
    case requestedVersionNotAvailableOnThisServer
    case clientHasSentToomanyRequests
    case resourceAccessForbiddenForThisUser
    case anotherResourceViolatesConstraint
    case internalServerError
    case serviceTemporaryUnavailableDueToHighLoad
    case serviceDeprecated
    case userExist
    case invalidUserName
    case usernameRequired
}

extension KintoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NoData:
            return NSLocalizedString("No Data", comment: "KintoError")
        case .missingAuthorizationToken:
            return NSLocalizedString("Missing Authorization Token", comment: "KintoError")
        case .invalidAuthorizationToken:
            return NSLocalizedString("Invalid Authorization Token", comment: "KintoError")
        case .requestBodyWasNotValidJSON:
            return NSLocalizedString("Request Body Was Not Valid JSON", comment: "KintoError")
        case .invalidRequestParameter:
            return NSLocalizedString("Invalid Request Parameter", comment: "KintoError")
        case .missingRequestParameter:
            return NSLocalizedString("Missing Request Parameter", comment: "KintoError")
        case .invalidPostedData:
            return NSLocalizedString("Invalid Posted Data", comment: "KintoError")
        case .invalidTokenId:
            return NSLocalizedString("Invalid Token Id", comment: "KintoError")
        case .missingTokenId:
            return NSLocalizedString("Missing Token Id", comment: "KintoError")
        case .contentLengthHeaderWasNotProvided:
            return NSLocalizedString("Content Length Header Was Not Provided", comment: "KintoError")
        case .requestBodyTooLarge:
            return NSLocalizedString("Request Body Too Large", comment: "KintoError")
        case .resourceWasModifiedMeanwhile:
            return NSLocalizedString("Resource Was Modified Meanwhile", comment: "KintoError")
        case .methodNotAllowedOnThisEndPoint:
            return NSLocalizedString("Method Not Allowed On This EndPoint", comment: "KintoError")
        case .requestedVersionNotAvailableOnThisServer:
            return NSLocalizedString("Requested Version Not Available On This Server", comment: "KintoError")
        case .clientHasSentToomanyRequests:
            return NSLocalizedString("Client Has Sent Too many Requests", comment: "KintoError")
        case .resourceAccessForbiddenForThisUser:
            return NSLocalizedString("Resource Access Forbidden For This User", comment: "KintoError")
        case .anotherResourceViolatesConstraint:
            return NSLocalizedString("Another Resource Violates Constraint", comment: "KintoError")
        case .internalServerError:
            return NSLocalizedString("Internal Server Error", comment: "KintoError")
        case .serviceTemporaryUnavailableDueToHighLoad:
            return NSLocalizedString("Service Temporary Unavailable Due To HighLoad", comment: "KintoError")
        case .serviceDeprecated:
            return NSLocalizedString("Service Deprecated", comment: "KintoError")
        case .userExist:
            return NSLocalizedString("Account already exists for this username.", comment: "KintoError")
            
        case .invalidUserName:
            return NSLocalizedString("Invalid username or password", comment: "KintoError")
            
        case .usernameRequired:
            return NSLocalizedString("Username is Required ", comment: "KintoError")
        }
    }
}

extension KintoError: CustomNSError{
    public static var errorDomain: String {
        return ""
    }
    public var errorCode: Int {
        switch self {
        case .NoData:
            return 1
        case .missingAuthorizationToken:
            return 104
        case .invalidAuthorizationToken:
            return 105
        case .requestBodyWasNotValidJSON:
            return 106
        case .invalidRequestParameter:
            return 107
        case .missingRequestParameter:
            return 108
        case .invalidPostedData:
            return 109
        case .invalidTokenId:
            return 110
        case .missingTokenId:
            return 111
        case .contentLengthHeaderWasNotProvided:
            return 112
        case .requestBodyTooLarge:
            return 113
        case .resourceWasModifiedMeanwhile:
            return 114
        case .methodNotAllowedOnThisEndPoint:
            return 115
        case .requestedVersionNotAvailableOnThisServer:
            return 116
        case .clientHasSentToomanyRequests:
            return 117
        case .resourceAccessForbiddenForThisUser:
            return 121
        case .anotherResourceViolatesConstraint:
            return 122
        case .internalServerError:
            return 999
        case .serviceTemporaryUnavailableDueToHighLoad:
            return 201
        case .serviceDeprecated:
            return 202
        case .userExist:
            return 2
        case .invalidUserName:
            return 3
        case .usernameRequired:
            return 4
            
        }
    }
}

func getErrorFromCode(_ code: Int) -> Error?{
    switch code {
    case 104:
        let error: Error = KintoError.missingAuthorizationToken
        return error;
    case 105:
        let error: Error = KintoError.invalidAuthorizationToken
        return error;
    case 106:
        let error: Error = KintoError.requestBodyWasNotValidJSON
        return error;
    case 107:
        let error: Error = KintoError.invalidRequestParameter
        return error;
    case 108:
        let error: Error = KintoError.missingRequestParameter
        return error;
    case 109:
        let error: Error = KintoError.invalidPostedData
        return error;
    case 110:
        let error: Error = KintoError.invalidTokenId
        return error;
    case 111:
        let error: Error = KintoError.missingTokenId
        return error;
    case 112:
        let error: Error = KintoError.contentLengthHeaderWasNotProvided
        return error;
    case 114:
        let error: Error = KintoError.resourceWasModifiedMeanwhile
        return error
    case 115:
        let error: Error = KintoError.methodNotAllowedOnThisEndPoint
        return error;
    case 116:
        let error: Error = KintoError.requestedVersionNotAvailableOnThisServer
        return error;
    case 117:
        let error: Error = KintoError.clientHasSentToomanyRequests
        return error;
    case 121:
        let error: Error = KintoError.resourceAccessForbiddenForThisUser
        return error;
    case 122:
        let error: Error = KintoError.anotherResourceViolatesConstraint
        return error;
    case 999:
        let error: Error = KintoError.internalServerError
        return error;
    case 201:
        let error: Error = KintoError.serviceTemporaryUnavailableDueToHighLoad
        return error;
    case 202:
        let error: Error = KintoError.serviceDeprecated
        return error;
        
    default:
        return nil
        
    }
}
