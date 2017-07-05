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
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNNotificationListViewController ()

@property (strong, nonatomic) id<NSObject> localNotificationChangeNotification;
@property (strong, nonatomic) __block NSArray<UNNotification *> *activeNotificationsList;

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
            NGNTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:taskListId];
            NGNTask *currentTask = [currentTaskList entityById:taskId];
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
        NGNTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:taskListId];
        NGNTask *currentTask = [currentTaskList entityById:taskId];
        editTaskViewController.entringTask = currentTask;
        editTaskViewController.entringTaskList = currentTaskList;
    }
}

#pragma mark - additional handling methods

// method helps to reload data on controller with renewed data from model
- (void)refreshData {
    [self reloadActiveNotificationsList];
    UIApplication.sharedApplication.applicationIconBadgeNumber = self.activeNotificationsList.count;
    NSString *badgeValue = self.activeNotificationsList.count == 0 ? nil :
                           [NSString stringWithFormat:@"%ld", self.activeNotificationsList.count];
    [[self.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:badgeValue];
    [self.tableView reloadData];
}

- (void)reloadActiveNotificationsList {
    self.activeNotificationsList = nil;
    while (!self.activeNotificationsList) {
        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:
         ^(NSArray<UNNotification *> *notifications) {
             self.activeNotificationsList = notifications;
         }];
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
                              ^BOOL(UNNotification *notification, NSDictionary *bindings){
                                  return [notification.request.identifier containsString:NGNNotificationRequestIDTaskTime];
                              }];
    self.activeNotificationsList = [self.activeNotificationsList filteredArrayUsingPredicate:predicate];
}

@end
