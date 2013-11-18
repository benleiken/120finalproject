//
//  AppDelegate.m
//  Mobile MessageHub
//
//  Created by Ben Leiken on 11/6/13.
//  Copyright (c) 2013 BKL. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // Register with apple that this app will use push notification
   [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                          UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
   
   // Your app startup logic...
   return YES;
}

-  (NSString*) stringFromDeviceTokenData:(NSData *) deviceToken
{
   const char *data = [deviceToken bytes];
   NSMutableString* token = [NSMutableString string];
   for (int i = 0; i < [deviceToken length]; i++) {
      [token appendFormat:@"%02.2hhX", data[i]];
   }
   
   return token;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
   NSLog(@"Error in registration. Error: %@", err);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
   
   // Convert the binary data token into an NSString (see below for the implementation of this function)
   NSString *deviceTokenAsString = [self stringFromDeviceTokenData:deviceToken];
   
   // Show the device token obtained from apple to the log
   NSLog(@"deviceToken: %@", deviceTokenAsString);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
