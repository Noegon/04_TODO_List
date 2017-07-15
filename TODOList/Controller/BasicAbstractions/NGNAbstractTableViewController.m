//
//  NGNAbstractTableViewController.m
//  TODOList
//
//  Created by Alex on 17.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import <CoreData/CoreData.h>

#import "NGNAbstractTableViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"
#import "NGNLocalizationConstants.h"

@interface NGNAbstractTableViewController () <UITableViewDataSource,
                                              UITableViewDelegate,
                                              UIGestureRecognizerDelegate>

#pragma mark - additional handling methods

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;

#pragma mark - gestures handling

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;

@end

@implementation NGNAbstractTableViewController

#pragma mark - additional handling methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return NGNControllerTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NGNControllerTableRowHeight;
}

- (void)performTaskDeleteConfirmationDialogueAtTableView:(UITableView *)tableView
                                             atIndexPath:(NSIndexPath *)indexPath
                                       withStoreableItem:(NSManagedObject *)storeableItem {
    UIAlertController *alertViewController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(NGNLocalizationKeyControllerDeleteAlertTitle, nil)
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:
                                   NSLocalizedString(NGNLocalizationKeyControllerCancelButtonTitle, nil)
                                                           style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:cancelAction];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:
                                   NSLocalizedString(NGNLocalizationKeyControllerDeleteButtonTitle, nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        if ([storeableItem isKindOfClass:[NGNManagedTask class]]) {
            NSString *notificationID =
                [NSString stringWithFormat:@"%@%lld", NGNNotificationRequestIDTaskTime,
                    ((NGNManagedTask *)storeableItem).entityId];
            [[UNUserNotificationCenter currentNotificationCenter]
                removeDeliveredNotificationsWithIdentifiers:@[notificationID]];
            [[UNUserNotificationCenter currentNotificationCenter]
                removePendingNotificationRequestsWithIdentifiers:@[notificationID]];
            [[NGNTaskService sharedInstance] removeTask:(NGNManagedTask *)storeableItem];
        } else if ([storeableItem isKindOfClass:[NGNManagedTaskList class]]) {
            [[NGNTaskService sharedInstance] removeEntity:(NGNManagedTaskList *)storeableItem];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameGlobalModelChange
                                                            object:nil
                                                          userInfo:nil];
    }];
    [alertViewController addAction:deleteAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - additional handling methods

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *doneBarButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(NGNLocalizationKeyControllerDoneButtonTitle, nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(doneBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneBarButton;
    [self.tableView setEditing:YES];
    doneBarButton = nil;
}

- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *editBarButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(NGNLocalizationKeyControllerEditButtonTitle, nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(editBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = editBarButton;
    [self.tableView setEditing:NO];
    editBarButton = nil;
}

#pragma mark - gestures handling

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (self.tableView.isEditing) {
        [self doneBarButtonTapped:nil];
    } else {
        [self editBarButtonTapped:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_taskAddNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_taskChangeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_taskListAddNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_taskListChangeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_globalModelChangeNotification];
}

@end
