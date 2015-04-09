//
//  YTKKeyValueStore.m
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import "YTKKeyValueStore.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#ifdef DEBUG
#define debugLog(...)    NSLog(__VA_ARGS__)
#define debugMethod()    NSLog(@"%s", __func__)
#define debugError()     NSLog(@"Error at %s Line:%d", __func__, __LINE__)
#else
#define debugLog(...)
#define debugMethod()
#define debugError()
#endif

#pragma mark -
typedef NS_ENUM(NSUInteger, StoreValueType) {
    kStoreValueType_String,
    kStoreValueType_Number,
    kStoreValueType_Collection,     //  JSON, NSArray, NSDictionary, NSData ...
    kStoreValueType_Error,          //  非法数据
};

@interface YTKKeyValueItem : NSObject
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) id value;
@property (assign, nonatomic) StoreValueType type;
@property (strong, nonatomic) NSDate *createdTime;
@end

@implementation YTKKeyValueItem

- (NSString *)description {
    return [NSString stringWithFormat:@"id=%@, value=%@, timeStamp=%@", _key, _value, _createdTime];
}

@end

#pragma mark -
@interface YTKKeyValueStore()

@property (strong, nonatomic) FMDatabaseQueue * dbQueue;

@end


@implementation YTKKeyValueStore

static NSString *const kDefault_DB_Name = @"database.sqlite";
static NSString *const kDefault_Table_Name = @"store_table";

static NSString *const kCreate_Table_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT NOT NULL, \
type integer NOT NULL, \
createdTime TEXT NOT NULL, \
PRIMARY KEY(id)) \
";

static NSString *const kUpdate_Item_SQL = @"REPLACE INTO %@ (id, json, type, createdTime) values (?, ?, ?, ?)";
static NSString *const kQuery_Item_SQL = @"SELECT json, type, createdTime from %@ where id = ? Limit 1";

static NSString *const kSelect_All_SQL = @"SELECT * from %@";
static NSString *const kClear_All_SQL = @"DELETE from %@";

static NSString *const kDelete_Item_SQL = @"DELETE from %@ where id = ?";
static NSString *const kDelete_Items_SQL = @"DELETE from %@ where id in ( %@ )";
static NSString *const kDelete_Items_With_Prefix_SQL = @"DELETE from %@ where id like ? ";


+ (BOOL)checkTableName:(NSString *)tableName {
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        debugLog(@"ERROR, table name: %@ format error.", tableName);
        return NO;
    }
    return YES;
}

- (id)initWithDBWithPath:(NSString *)dbPath {

    if (self = [super init]) {
        debugLog(@"dbPath = %@", dbPath);
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self createTableWithName:kDefault_Table_Name];
    }
    return self;
}

- (void)createTableWithName:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:kCreate_Table_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to create table: %@", tableName);
    }
}

- (void)clearTableWithName:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:kClear_All_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to clear table: %@", tableName);
    }
}

- (StoreValueType)typeWithValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return kStoreValueType_String;
    }else if ([value isKindOfClass:[NSNumber class]]) {
        return kStoreValueType_Number;
    }else{
        return kStoreValueType_Collection;
    }
}

#pragma mark - default table
- (void)putValue:(id)value forKey:(NSString *)key {
    [self putValue:value forKey:key intoTable:kDefault_Table_Name];
}
- (id)valueForKey:(NSString *)key {
    return [self valueForKey:key fromTable:kDefault_Table_Name];
}

#pragma mark - custom table
- (void)putValue:(id)value forKey:(NSString *)key intoTable:(NSString *)tableName {
    
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    
    StoreValueType type = [self typeWithValue:value];
    if (type == kStoreValueType_Error) {
        return;
    }
    
    //  number => array
    if (type == kStoreValueType_Number) {
        value = @[value];
    }
    
    //  NSData, NSNumber, NSArray, NSDictionary => JSON String
    if (type == kStoreValueType_Number || type == kStoreValueType_Collection) {
        NSError * error;
        NSData * data = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
        if (error) {
            debugLog(@"ERROR, faild to get json data");
            return;
        }
        value = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    }
    
    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:kUpdate_Item_SQL, tableName];
    
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, key, value, @(type), createdTime];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to insert/replace into table: %@", tableName);
    }
}

- (id)valueForKey:(NSString *)key fromTable:(NSString *)tableName {
    YTKKeyValueItem * item = [self itemForKey:key fromTable:tableName];
    if (item) {
        return item.value;
    } else {
        return nil;
    }
}

- (YTKKeyValueItem *)itemForKey:(NSString *)key fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:kQuery_Item_SQL, tableName];
    __block NSString * content = nil;
    __block NSDate * createdTime = nil;
    __block NSInteger type = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql, key];
        if ([rs next]) {
            type = [rs intForColumn:@"type"];
            content = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    
    if (content) {
        
        id result = nil;
        if (type == kStoreValueType_String) {
            result = content;
        }
        
        //  numuber = array[0]
        if (type == kStoreValueType_Collection || type == kStoreValueType_Number) {
            NSError * error;
            result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:(NSJSONReadingAllowFragments) error:&error];
            if (error) {
                debugLog(@"ERROR, faild to prase to json");
                return nil;
            }
        }
        
        if (type == kStoreValueType_Number) {
            result = [result objectAtIndex:0];
        }
        
        YTKKeyValueItem * item = [[YTKKeyValueItem alloc] init];
        item.key = key;
        item.value = result;
        item.createdTime = createdTime;
        item.type = type;
        return item;
    } else {
        return nil;
    }
}

- (NSArray *)allItemsFromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:kSelect_All_SQL, tableName];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            YTKKeyValueItem * item = [[YTKKeyValueItem alloc] init];
            item.key = [rs stringForColumn:@"id"];
            item.value = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    // parse json string to value
    NSError * error;
    for (YTKKeyValueItem * item in result) {
        error = nil;
        id value = [NSJSONSerialization JSONObjectWithData:[item.value dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            debugLog(@"ERROR, faild to prase to json.");
        } else {
            item.value = value;
        }
    }
    return result;
}

- (void)removeValueForKey:(NSString *)key fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:kDelete_Item_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, key];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to delete item from table: %@", tableName);
    }
}

- (void)removeValuesForKeys:(NSArray *)keys fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id key in keys) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", key];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql = [NSString stringWithFormat:kDelete_Items_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to delete items by ids from table: %@", tableName);
    }
}

- (void)removeValuesByKeyPrefix:(NSString *)keyPrefix fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:kDelete_Items_With_Prefix_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", keyPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to delete items by id prefix from table: %@", tableName);
    }
}

- (void)close {
    [_dbQueue close];
    _dbQueue = nil;
}

@end
