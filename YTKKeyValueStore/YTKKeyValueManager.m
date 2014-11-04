//
//  YTKKeyValueManager.m
//  YTKKeyValueStore
//
//  Created by Arthur on 14/11/4.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

#import "YTKKeyValueManager.h"

@interface YTKKeyValueManager ()

@property (nonatomic, strong) NSMutableDictionary* stores;

@end

@implementation YTKKeyValueManager

+ (YTKKeyValueManager*)defaultKeyValueManager {
  static YTKKeyValueManager* manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ manager = [[YTKKeyValueManager alloc] init]; });

  return manager;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.stores = [[NSMutableDictionary alloc] init];
  }

  return self;
}

+ (YTKKeyValueStore*)getKeyValueStoreWithName:(NSString*)name {
  if (name.length == 0) {
    return nil;
  }

  NSString* path = [[NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
      stringByAppendingPathComponent:name];

  return [YTKKeyValueManager getKeyValueStoreWithPath:path];
}

+ (YTKKeyValueStore*)getKeyValueStoreWithPath:(NSString*)path {
  if (path.length == 0) {
    return nil;
  }

  YTKKeyValueManager* manager = [YTKKeyValueManager defaultKeyValueManager];

  if ([manager.stores objectForKey:path]) {
    return [manager.stores objectForKey:path];
  } else {
    YTKKeyValueStore* store =
        [[YTKKeyValueStore alloc] initWithDBWithPath:path];
    if (store) {
      [manager.stores setObject:store forKey:path];
      return store;
    }
  }

  return nil;
}

+ (void)closeKeyValueWith:(YTKKeyValueStore*)store {
  YTKKeyValueManager* manager = [YTKKeyValueManager defaultKeyValueManager];
  NSString* deleteKey = nil;

  NSArray* keys = [manager.stores allKeys];
  for (NSString* key in keys) {
    id object = [manager.stores objectForKey:key];
    if (object == store) {
      deleteKey = key;
      break;
    }
  }

  if (deleteKey) {
    [store close];
    [manager.stores removeObjectForKey:deleteKey];
  }
}

@end
