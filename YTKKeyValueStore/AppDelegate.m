//
//  AppDelegate.m
//  YTKKeyValueStore
//
//  Created by TangQiao on 10/3/14.
//  Copyright (c) 2014 TangQiao. All rights reserved.
//

#import "AppDelegate.h"
#import "YTKKeyValueStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Demo
    NSString *tableName = @"user_table";
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"test.db"];
    [store createTableWithName:tableName];
    NSString *key = @"1";
    NSDictionary *user = @{@"id": @1, @"name": @"tangqiao", @"age": @30};
    [store putObject:user withId:key intoTable:tableName];
    
    NSDictionary *queryUser = [store getObjectById:key fromTable:tableName];
    NSLog(@"query data result: %@", queryUser);

    // Demo
    NSString *encryptTableName = @"encrypt_user_table";
    YTKKeyValueStore *encryptStore = [[YTKKeyValueStore alloc] initDBWithName:@"test.encrypt.db" withEncryptKey:@"encrypt.key"];
    [encryptStore createTableWithName:encryptTableName];
    NSString *encryptKey = @"zhenian";
    NSDictionary *encryptUser = @{@"id": @2, @"name": @"gelosie", @"age": @31};
    [encryptStore putObject:encryptUser withId:encryptKey intoTable:encryptTableName];

    NSDictionary *encryptQueryUser = [encryptStore getObjectById:encryptKey fromTable:encryptTableName];
    NSLog(@"query encrypt data result: %@", encryptQueryUser);

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
