//
//  SwiftDemo.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit

class SwiftDemo : NSObject{
    class func test(){
        let tableName = "user_table_swift"
        var store = YTKKeyValueStore_Swift(dbName: "test_siwft.db")
        store.createTable(tableName: tableName)
        let key = "1"
        let user = ["id":1 , "name" : "tangqiao" , "age" : 30]
        store.putObject(user, withId: key, intoTable: tableName)
    
        if let queryUser: AnyObject = store.getObjectById(key, fromTable: tableName){
            println("[swift] query data result: \(queryUser)")
        }
    }
}