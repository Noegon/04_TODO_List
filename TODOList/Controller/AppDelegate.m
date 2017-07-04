//
//  AppDelegate.m
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "AppDelegate.h"
#import "NGNEditTaskViewController.h"
#import "NGNInboxViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"
#import "NSDate+NGNDateToStringConverter.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              NSLog(@"Notifications allowed");
                              center.delegate = self;
                          }];
    // Set the tab bar number badge
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    UITabBarItem *tab_bar = [[tabBarController.viewControllers objectAtIndex:4] tabBarItem];
    // Show the badge if the count is
    // greater than 0 otherwise hide it.
    if (UIApplication.sharedApplication.applicationIconBadgeNumber > 0) {
        [tab_bar setBadgeValue:[NSString stringWithFormat:@"%ld",
                                UIApplication.sharedApplication.applicationIconBadgeNumber]]; // set your badge value
    } else {
        [tab_bar setBadgeValue:nil];
    }
    return YES;
}

//This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. !
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    application.applicationIconBadgeNumber += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameLocalNotificationListChanged
                                                        object:nil
                                                      userInfo:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //for debug
    //    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    //    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameLocalNotificationListChanged
                                                        object:nil
                                                      userInfo:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UNUserNotificationCenterDelegate methods

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert +
                      UNNotificationPresentationOptionSound);
    [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameLocalNotificationListChanged
                                                        object:nil
                                                      userInfo:nil];
}

//method calling when user tap on pop-up window with notification alert
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)())completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert +
                      UNNotificationPresentationOptionSound);
    //reduce badge number
    UIApplication.sharedApplication.applicationIconBadgeNumber -= 1;
    //get initial parameters for target view controller
    NSNumber *taskListId = response.notification.request.content.userInfo[@"taskListId"];
    NGNTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:taskListId.integerValue];
    NSNumber *taskId = response.notification.request.content.userInfo[@"taskId"];
    NGNTask *currentTask = [currentTaskList entityById:taskId.integerValue];
    //get target controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NGNEditTaskViewController *editTaskViewController =
    [storyboard instantiateViewControllerWithIdentifier:NGNControllerIdentifierEditTask];
    //set initial parameters for target view controller
    editTaskViewController.entringTaskList = currentTaskList;
    editTaskViewController.entringTask = currentTask;
    //get opening view controller
    UITabBarController *tbc = (UITabBarController*)self.window.rootViewController;
    tbc.selectedIndex = 0;
    NGNInboxViewController *inboxController = (NGNInboxViewController *)tbc.selectedViewController;
    //push from opening to target view controller
    [(UINavigationController *)inboxController pushViewController:editTaskViewController animated:NO];
}


@end
