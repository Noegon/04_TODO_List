//
//  NGNNotificationListViewController.m
//  TODOList
//
//  Created by Alex on 23.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "NGNNotificationListViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNNotificationListViewController ()

@property (strong, nonatomic) id<NSObject> localNotificationChangeNotification;
@property (strong, nonatomic) __block NSArray<UNNotification *> *activeNotificationsList;

@property (retain, nonatomic) dispatch_queue_t myQueue;
@property (retain, nonatomic) dispatch_group_t myGroup;

#pragma mark - additional handling methods
//- (void)refreshData;
//- (void)reloadActiveNotificationsList;

@end

@implementation NGNNotificationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskChangeNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.taskAddNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.taskListChangeNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.taskListAddNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListAdd
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.globalModelChangeNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.localNotificationChangeNotification =
        [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameLocalNotificationListChanged
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    if (!self.activeNotificationsList) {
        [self refreshData];
    }
}

- (dispatch_queue_t)myQueue {
    if (!_myQueue) {
        return dispatch_queue_create("com.noegon.myqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _myQueue;
}

- (dispatch_group_t)myGroup {
    if (!_myGroup) {
        return dispatch_group_create();
    }
    return _myGroup;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activeNotificationsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    if (self.activeNotificationsList.count != 0) {
        UNNotificationContent *objNotificationContent = self.activeNotificationsList[indexPath.row].request.content;
        if (objNotificationContent) {
            NSInteger taskId = ((NSNumber *)[objNotificationContent.userInfo valueForKey:@"taskId"]).integerValue;
            NSInteger taskListId = ((NSNumber *)[objNotificationContent.userInfo valueForKey:@"taskListId"]).integerValue;
            NGNManagedTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:taskListId];
            NGNManagedTask *currentTask = [currentTaskList entityById:taskId];
            taskCell.textLabel.text = currentTask.name;
        }
    }
    return taskCell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        UNNotificationContent *objNotificationContent = self.activeNotificationsList[indexPath.row].request.content;
        NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
        NSInteger taskId = ((NSNumber *)[objNotificationContent.userInfo valueForKey:@"taskId"]).integerValue;
        NSInteger taskListId = ((NSNumber *)[objNotificationContent.userInfo valueForKey:@"taskListId"]).integerValue;
        NGNManagedTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:taskListId];
        NGNManagedTask *currentTask = [currentTaskList entityById:taskId];
        editTaskViewController.entringTask = currentTask;
        editTaskViewController.entringTaskList = currentTaskList;
    }
}

#pragma mark - additional handling methods

// method helps to reload data on controller with renewed data from model
- (void)refreshData {
    dispatch_group_t group = dispatch_group_create();
    dispatch_async(self.myQueue, ^{
        
        dispatch_group_enter(group);
        self.activeNotificationsList = nil;
        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:
         ^(NSArray<UNNotification *> *notifications) {
             dispatch_group_async(group, self.myQueue, ^{
                 self.activeNotificationsList = notifications;
                 //             [self.tableView reloadData];
                 dispatch_group_leave(group);
             });
         }];
        
        dispatch_wait(group, DISPATCH_TIME_FOREVER);
        
        dispatch_group_enter(group);
        dispatch_group_async(group, self.myQueue, ^{
            NSPredicate *predicate = [NSPredicate predicateWithBlock:
                                      ^BOOL(UNNotification *notification, NSDictionary *bindings){
                                          return [notification.request.identifier containsString:NGNNotificationRequestIDTaskTime];
                                      }];
            self.activeNotificationsList = [self.activeNotificationsList filteredArrayUsingPredicate:predicate];
            dispatch_group_leave(group);
        });
        
        dispatch_wait(group, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication.sharedApplication.applicationIconBadgeNumber = self.activeNotificationsList.count;
            NSString *badgeValue = self.activeNotificationsList.count == 0 ? nil :
            [NSString stringWithFormat:@"%ld", (unsigned long)self.activeNotificationsList.count];
            [[self.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:badgeValue];
            [self.tableView reloadData];
        });
    });
}

//- (void)reloadActiveNotificationsListWithGroup:(dispatch_group_t)group {
//    dispatch_async(self.myQueue, ^{
//        self.activeNotificationsList = nil;
//        
//        dispatch_group_enter(group);
//        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:
//         ^(NSArray<UNNotification *> *notifications) {
//             dispatch_group_async(group, self.myQueue, ^{
//             self.activeNotificationsList = notifications;
////             [self.tableView reloadData];
//                 dispatch_group_leave(group);
//             });
//         }];
//        
//        dispatch_wait(group, DISPATCH_TIME_FOREVER);
//        
//        dispatch_group_enter(group);
//        dispatch_group_async(group, self.myQueue, ^{
//            NSPredicate *predicate = [NSPredicate predicateWithBlock:
//                                      ^BOOL(UNNotification *notification, NSDictionary *bindings){
//                                          return [notification.request.identifier containsString:NGNNotificationRequestIDTaskTime];
//                                      }];
//            self.activeNotificationsList = [self.activeNotificationsList filteredArrayUsingPredicate:predicate];
//            dispatch_group_leave(group);
//        });
//        
//        dispatch_wait(group, DISPATCH_TIME_FOREVER);
//    });
//}

@end
