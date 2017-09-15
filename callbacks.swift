//
//  callbacks.swift
//  Kinto_Example
//
//  Created by user on 23/06/2017.
//  Copyright © 2017 Karizma LTD. All rights reserved.
//

public typealias KintoUserLogoutResultBlock = (Error?) -> Void
public typealias KintoQueryArrayResultBlock = ([KintoObject]?, Error?) -> Void
public typealias KintoQueryObjectResultBlock = (KintoObject?, Error?) -> Void
public typealias KintoBooleanResultBlock = (Bool, Error?) -> Void
public typealias KintoUserResultBlock = (KintoUser?, Error?) -> Void
public typealias KintoIntegerResultBlock = (Int32?, Error?) -> Void
