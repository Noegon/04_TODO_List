//
//  NGNProjectsViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNToDoListViewController.h"
#import "NGNTaskListDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNToDoListViewController () <UITableViewDataSource, UITableViewDelegate>


#pragma mark - additional handling methods
- (NGNTaskList *)actualTaskListWithIndexPath:(NSIndexPath *)indexPath;
- (void)addTaskList;

@end

@implementation NGNToDoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListAdd
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [[NGNTaskService sharedInstance] entityCollection].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:indexPath];
    UITableViewCell *taskCell;
    if (currentTaskList) {
         taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskListCellIdentifier
                                                    forIndexPath:indexPath];

        taskCell.textLabel.text = currentTaskList.name;
        taskCell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)", [currentTaskList entityCollection].count];
    } else {
        taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerAddProjectCellIdentifier
                                                   forIndexPath:indexPath];
        UITapGestureRecognizer *tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(addTaskList)];
        [taskCell addGestureRecognizer:tapGestureRecognizer];
//        taskCell.textLabel.text = @"Add project";
//        taskCell.detailTextLabel.text = @"";
    }
    if (indexPath.section != 0) {
        if (indexPath.row == 0) {
            [taskCell setEditing:YES animated:YES];
        }
    }
    return taskCell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section != 0 && indexPath.row != 0) {
            
            NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:indexPath];
            
            [self performTaskDeleteConfirmationDialogueAtTableView:tableView
                                                       atIndexPath:indexPath
                                                 withStoreableItem:currentTaskList];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addTaskList];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        if (indexPath.row != 0) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

// Override to insert some additional functionality to cell when you swipe left
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //edit row action (edit project name)
    UITableViewRowAction *editAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:NGNControllerEditButtonTitle
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:indexPath];
                                         
        UIAlertController *alertViewController =
            [UIAlertController alertControllerWithTitle:NGNControllerEditProjectAlertTitle
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertViewController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"name";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.text = currentTaskList.name;
        }];
                                         
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NGNControllerCancelButtonTitle
                                                               style:UIAlertActionStyleCancel handler:nil];
        [alertViewController addAction:cancelAction];
                                         
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NGNControllerConfirmButtonTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
            currentTaskList.name = alertViewController.textFields[0].text;
            //notify everyone that taskList was changed
            NSDictionary *userInfo = @{@"taskList": currentTaskList};
            [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListChange
                                                                object:nil
                                                              userInfo:userInfo];
        }];
        [alertViewController addAction:confirmAction];
                                         
        [self presentViewController:alertViewController animated:YES completion:nil];
    }];
    // blue color button
    editAction.backgroundColor = [UIColor colorWithRed:NGNControllerBlueColorRedPortion
                                                 green:NGNControllerBlueColorGreenPortion
                                                  blue:NGNControllerBlueColorBluePortion alpha:1.];
    
    //delete row action
    UITableViewRowAction *deleteAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NGNControllerDeleteButtonTitle
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete
                                        forRowAtIndexPath:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction, editAction];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath.section == 1 && indexPath.row == 0) {
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddProject]) {
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskListDetail]) {
        NGNTaskListDetailsViewController *taskListDetailsViewController = segue.destinationViewController;
        NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:indexPath];
        taskListDetailsViewController.entringTaskList = currentTaskList;
    }
}

#pragma mark - additional handling methods

- (NGNTaskList *)actualTaskListWithIndexPath:(NSIndexPath *)indexPath {
    NGNTaskList *currentTaskList;
    if (indexPath.section == 0) {
        currentTaskList = [[NGNTaskService sharedInstance] entityById:999];
    } else {
        if (indexPath.row != 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.entityId != 999"];
            NSArray *filteredArray = [[NGNTaskService sharedInstance].entityCollection
                                      filteredArrayUsingPredicate:predicate];
            currentTaskList = filteredArray[indexPath.row - 1];
        }
    }
    return currentTaskList;
}

- (void)addTaskList {
    NGNTaskList *addingTaskList = [[NGNTaskList alloc] initWithId:foo4random() name:@"None"];
    [[NGNTaskService sharedInstance] addEntity:addingTaskList];
    NSDictionary *userInfo = @{@"taskList": addingTaskList};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListAdd
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
