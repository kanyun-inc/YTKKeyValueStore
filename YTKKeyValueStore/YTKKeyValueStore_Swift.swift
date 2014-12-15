//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit


class YTKKeyValueItem_Swift:NSObject{
    var itemId : String?
    var itemObject : AnyObject?
    var createdTime : NSDate?
    
    func description() -> String{
        return "id=\(itemId), value=\(itemObject), timeStamp=\(createdTime)"
    }
    
}


class YTKKeyValueStore_Swift: NSObject {
    
    //文件夹路径
    let PATH_OF_DOCUMENT : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
    
    private var dbQueue : FMDatabaseQueue?
    
    let DEFAULT_DB_NAME = "database_swift.sqlite"
    let CREATE_TABLE_SQL = "CREATE TABLE IF NOT EXISTS %@ ( id TEXT NOT NULL, json TEXT NOT NULL, createdTime TEXT NOT NULL, PRIMARY KEY(id)) "
    let UPDATE_ITEM_SQL = "REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)"
    let QUERY_ITEM_SQL = "SELECT json, createdTime from %@ where id = ? Limit 1"
    let SELECT_ALL_SQL = "SELECT * from %@"
    let CLEAR_ALL_SQL = "DELETE from %@"
    let DELETE_ITEM_SQL = "DELETE from %@ where id = ?"
    let DELETE_ITEMS_SQL = "DELETE from %@ where id in ( %@ )"
    let DELETE_ITEMS_WITH_PREFIX_SQL = "DELETE from %@ where id like ? "
    
    
    class func checkTableName(tableName : NSString!)->Bool{
        if(tableName.rangeOfString("").location != NSNotFound){
            println("error, table name: %@ format error",tableName)
            return false
        }
        return true
    }
    
    override init(){
        super.init()
        self.setupDB(DEFAULT_DB_NAME)
    }
    init(dbName : String!){
        super.init()
        self.setupDB(dbName)
    }
    
    private func setupDB(dbName : String!){
        let dbPath = PATH_OF_DOCUMENT.stringByAppendingPathComponent(dbName)
        if dbQueue != nil{
            self.close()
        }
        dbQueue = FMDatabaseQueue(path: dbPath)
    }
    
    /**
    创建表单
    
    :param: tableName 表单名
    */
    func createTable(#tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName) {
            return
        }
        let sql = NSString(format: CREATE_TABLE_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result! {
            println("error, failed to create table: %@",tableName)
        }
    }
    
    /**
    清除表单
    
    :param: tableName 表单名
    */
    func clearTable(#tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: CLEAR_ALL_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result!{
            println("error, failed to clear table: %@",tableName)
        }
    }
    
    /**
    加入数据
    
    :param: object    数据
    :param: objectId  数据索引
    :param: tableName 表单名
    */
    func putObject(object : AnyObject! , withId objectId: String! , intoTable tableName: String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        var error : NSError?
        var data = NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions(0), error: &error)
        if error != nil {
            println("error, faild to get json data")
            return
        }else{
            let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let createTime = NSDate()
            let sql = NSString(format: UPDATE_ITEM_SQL, tableName)
            var result : Bool?
            dbQueue?.inDatabase({ (db) -> Void in
                result = db.executeUpdate(sql, withArgumentsInArray:[objectId,jsonString!,createTime])
            })
        }
    }
    
    
    /**
    根据ID查找对象
    
    :param: objectId  对象索引
    :param: tableName 表单名
    
    :returns: 对象数据
    */
    func getObjectById(objectId : String! , fromTable tableName : String! )->AnyObject?{
        let item = self.getYTKKeyValueItemById(objectId, fromTable: tableName)
        if item != nil {
            return item!.itemObject
        }
        return nil
    }
    
    /**
    获取数据封装类型
    
    :param: objectId  对象索引
    :param: tableName 表单名
    
    :returns: 对象数据
    */
    func getYTKKeyValueItemById(objectId :String! , fromTable tableName : String! )->YTKKeyValueItem_Swift?{
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return nil
        }
        let sql = NSString(format: QUERY_ITEM_SQL, tableName)
        var json : String? = nil
        var createdTime : NSDate? = nil
        dbQueue?.inDatabase({ (db) -> Void in
            var rs : FMResultSet = db.executeQuery(sql, withArgumentsInArray: [objectId])
            if rs.next() {
                json = rs.stringForColumn("json")
                createdTime = rs.dateForColumn("createdTime")
            }
            rs.close()
        })
        if json != nil{
            var error : NSError?
            var result: AnyObject? = NSJSONSerialization.JSONObjectWithData(json!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
            if error != nil{
                println("error, faild to prase to json")
                return nil
            }
            var item = YTKKeyValueItem_Swift()
            item.itemId = objectId
            item.itemObject = result!
            item.createdTime = createdTime
            return item
        }else{
            return nil
        }
    }
    
    
    /**
    插入字符串
    
    :param: string    字符串
    :param: stringId  索引
    :param: tableName 表单名
    */
    func putString(string : String! , withId stringId : String! , intoTable tableName:String!){
        self.putObject([string], withId: stringId, intoTable: tableName)
    }
    
    /**
    获取字符串
    
    :param: stringId  索引
    :param: tableName 表单名
    
    :returns: 字符串
    */
    func getStringById(stringId : String! , fromTable tableName : String!)->String?{
        let array : AnyObject? = self.getObjectById(stringId, fromTable: tableName)
        if let result = array as? NSArray {
            return result[0] as? String
        }else{
            return nil
        }
    }
    
    /**
    插入数字
    
    :param: number    数字
    :param: numberId  索引
    :param: tableName 表单名
    */
    func putNumber(number : NSNumber! , withId numberId : String! , intoTable tableName : String!){
        self.putObject([number], withId: numberId, intoTable: tableName)
    }
    
    /**
    获取数字
    
    :param: numberId  索引
    :param: tableName 表单名
    
    :returns: 数字
    */
    func getNumberById(numberId : String! , fromTable tableName : String!)->NSNumber?{
        let array : AnyObject? = self.getObjectById(numberId, fromTable: tableName)
        if let result = array as? NSArray {
            return result[0] as? NSNumber
        }else{
            return nil
        }
    }
    
    /**
    获取表单的所有的数据
    
    :param: tableName 表单名
    
    :returns: 所有数据
    */
    func getAllItemsFromTable(tableName : String!)->[AnyObject]?{
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return nil
        }
        let sql = NSString(format: SELECT_ALL_SQL, tableName)
        var result : [AnyObject] = []
        dbQueue?.inDatabase({ (db) -> Void in
            var rs : FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while(rs.next()){
                var item = YTKKeyValueItem_Swift()
                item.itemId = rs.stringForColumn("id")
                item.itemObject = rs.stringForColumn("json")
                item.createdTime = rs.dateForColumn("createdTime")
                result.append(item)
            }
            rs.close()
        })
        var error : NSError?
        
        for i in 0..<result.count {
            var item: YTKKeyValueItem_Swift = result[i] as YTKKeyValueItem_Swift
            error = nil
            var object: AnyObject? = NSJSONSerialization.JSONObjectWithData(item.itemObject!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
            if error != nil {
                println("error, faild to prase to json.")
            }else{
                item.itemObject = object!
                result[i] = item
            }
        }
        
        return result
    }
    
    /**
    根据所以删除数据
    
    :param: objectId  索引
    :param: tableName 表单名
    */
    func deleteObjectById(objectId : String! , fromTable tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: DELETE_ITEM_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:[objectId])
        })
        if !result! {
            println("error, failed to delete time from table: %@", tableName)
        }
    }
    
    /**
    根据索引数组删除数据
    
    :param: objectIdArray 索引数组
    :param: tableName     表单名
    */
    func deleteObjectsByIdArray(objectIdArray:[AnyObject]! , fromTable tableName : String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        var stringBuilder = NSMutableString()
        for objectId in objectIdArray{
            var item = " '\(objectId)' "
            if stringBuilder.length == 0 {
                stringBuilder.appendString("item")
            }else{
                stringBuilder.appendString(",")
                stringBuilder.appendString(item)
            }
        }
        let sql = NSString(format: DELETE_ITEMS_SQL, tableName,stringBuilder)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result!{
            println("error, failed to delete items by ids from table: %@",tableName)
        }
    }
    
    /**
    根据索引前缀删除数据
    
    :param: objectIdPrefix 索引前缀
    :param: tableName      表单名
    */
    func deleteObjectsByIdPrefix(objectIdPrefix :String , fromTable tableName:String){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: DELETE_ITEMS_WITH_PREFIX_SQL, tableName)
        let prefixArgument = NSString(format: "%@%%", objectIdPrefix)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result!{
            println("error, failed to delete items by id prefix from table: %@",tableName)
        }
    }
    
    /**
    关闭数据库
    */
    func close(){
        dbQueue?.close()
        dbQueue = nil
    }
    
}

