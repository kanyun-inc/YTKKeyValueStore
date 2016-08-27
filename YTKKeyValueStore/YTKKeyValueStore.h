//
//  YTKKeyValueStore.h
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTKKeyValueItem : NSObject

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) id itemObject;
@property (strong, nonatomic) NSDate *createdTime;

@end


@interface YTKKeyValueStore : NSObject

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)dropTable:(NSString *)tableName;

- (void)close;

///************************ Put&Get methods *****************************************

- (void)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (YTKKeyValueItem *)getYTKKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemsFromTable:(NSString *)tableName;
- (NSArray *)getAllIdFromTable:(NSString *)tableName;

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;


@end
/**
 *  简单粗暴的封装一层
 */
@interface YTDB : YTKKeyValueStore
/**
 *  直接传入对象保存,object传入nil时删除数据,不传入table名称时都传入default表
 */
+(void)putObject:(id)object fromId:(NSString *)objectId;
+(void)putObject:(id)object fromId:(NSString *)objectId formTable:(NSString *)table;
/**
 *  获取对象
 */
+(id)getObjectById:(NSString *)objectId;
+(id)getObjectById:(NSString *)objectId fromTable:(NSString *)table;

/**
 *  删除表
 */
+(void)deleteDefaultTable;
+(void)deleteTable:(NSString *)table;
@end
