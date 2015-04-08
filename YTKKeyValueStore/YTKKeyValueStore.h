//
//  YTKKeyValueStore.h
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, StoreValueType) {
    kStoreValueType_String,
    kStoreValueType_Number,
    kStoreValueType_Collection,   //  JSON, NSArray, NSDictionary, NSData ...
};

@interface YTKKeyValueItem : NSObject

@property (strong, nonatomic) NSString *itemID;
@property (strong, nonatomic) id itemObject;
@property (assign, nonatomic) StoreValueType type;
@property (strong, nonatomic) NSDate *createdTime;
@end


@interface YTKKeyValueStore : NSObject

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;

///************************ Put&Get methods *****************************************

- (StoreValueType)typeWithValue:(id)value;

- (void)putObject:(id)object withID:(NSString *)objectID intoTable:(NSString *)tableName;

- (id)objectByID:(NSString *)objectID fromTable:(NSString *)tableName;

- (YTKKeyValueItem *)getYTKKeyValueItemByID:(NSString *)objectID fromTable:(NSString *)tableName;


- (NSArray *)getAllItemsFromTable:(NSString *)tableName;

- (void)deleteobjectByID:(NSString *)objectID fromTable:(NSString *)tableName;

- (void)deleteObjectsByIDArray:(NSArray *)objectIDArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIDPrefix:(NSString *)objectIDPrefix fromTable:(NSString *)tableName;


@end
