//
//  YTKKeyValueStore.h
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>

//  Help you store anything string data to sqlite.
@interface YTKKeyValueStore : NSObject


//  init & close
- (id)initWithDBWithPath:(NSString *)dbPath;
- (void)createTableWithName:(NSString *)tableName;
- (void)clearTableWithName:(NSString *)tableName;
- (void)close;


//  use default table
- (void)putValue:(id)object forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;


//  use custom table
- (void)putValue:(id)object forKey:(NSString *)key intoTable:(NSString *)tableName;
- (id)valueForKey:(NSString *)key fromTable:(NSString *)tableName;


//  clear
- (void)removeValueForKey:(NSString *)key fromTable:(NSString *)tableName;
- (void)removeValuesForKeys:(NSArray *)keys fromTable:(NSString *)tableName;

//  模糊前缀删除, SQL = delete + like prefix%%
- (void)removeValuesByKeyPrefix:(NSString *)keyPrefix fromTable:(NSString *)tableName;


@end
