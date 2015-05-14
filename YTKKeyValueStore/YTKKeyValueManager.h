//
//  YTKKeyValueManager.h
//  YTKKeyValueStore
//
//  Created by Arthur on 14/11/4.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"

@interface YTKKeyValueManager : NSObject

+ (YTKKeyValueStore *)getKeyValueStoreWithName:(NSString *)name;
+ (YTKKeyValueStore *)getKeyValueStoreWithPath:(NSString *)path;
+ (void)closeKeyValueWith:(YTKKeyValueStore *)store;

@end
