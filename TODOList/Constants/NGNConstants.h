//
//  NGNConstants.h
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define foo4random() (arc4random() % ((unsigned)RAND_MAX + 1))

#pragma mark - model priorities
typedef enum {
    NGNNonePriority, NGNLowPriority, NGNMediumPriority, NGNHighPriority
} const NGNPriorities;

#pragma mark - model constants
static NSString *const NGNModelDateFormatForComparison = @"yyyy-LL-dd";

#pragma mark - controller constants
//cell identifiers
static NSString *const NGNControllerTaskCellIdentifier = @"NGNTaskCell";
static NSString *const NGNControllerTaskListCellIdentifier = @"NGNTaskListCell";
static NSString *const NGNControllerAddProjectCellIdentifier = @"NGNAddProjectCell";

static NSString *const NGNControllerShowingDateFormat = @"dd.LL.yyyy";
static double const NGNControllerTableSectionHeaderHeight = 22.;
static double const NGNControllerTableRowHeight = 70.;
static double const NGNControllerTableHeaderHeight = 60.;

#pragma mark - colors
//blue color
static double const NGNControllerBlueColorRedPortion = 0.086;
static double const NGNControllerBlueColorGreenPortion = 0.477;
static double const NGNControllerBlueColorBluePortion = 1;

#pragma mark - some view titles
//button titles
static NSString *const NGNControllerSaveButtonTitle = @"Save";
static NSString *const NGNControllerEditButtonTitle = @"Edit";
static NSString *const NGNControllerDoneButtonTitle = @"Done";
static NSString *const NGNControllerCancelButtonTitle = @"Cancel";
static NSString *const NGNControllerDeleteButtonTitle = @"Delete";
static NSString *const NGNControllerConfirmButtonTitle = @"Confirm";

//segment control titles
static NSString *const NGNControllerDateSegmentControlTitle = @"Date";
static NSString *const NGNControllerGroupSegmentControlTitle = @"Group";

//navigation item titles
static NSString *const NGNControllerAddTaskNavigationItemTitle = @"Add task";
static NSString *const NGNControllerEditTaskNavigationItemTitle = @"Edit task";

//search bar scope panel titles
static NSString *const NGNControllerActiveTasksSearchBarScopeTitle = @"Active tasks";
static NSString *const NGNControllerCompletedTasksSearchBarScopeTitle = @"Completed tasks";

//alert dialogue titles
static NSString *const NGNControllerDeleteAlertTitle = @"Do you want to remove item?";
static NSString *const NGNControllerEditProjectAlertTitle = @"Change project name";

//section headers titles
static NSString *const NGNControllerActiveTasksSectionTitle = @"Active";
static NSString *const NGNControllerCompletedTasksSectionTitle = @"Completed";

//other titles
static NSString *const NGNControllerNoneTitle = @"None";

#pragma mark - segues identifiers
static NSString *const NGNControllerSegueShowTaskDetail = @"ShowTaskDetail";
static NSString *const NGNControllerSegueShowTaskListDetail = @"ShowTaskListDetail";
static NSString *const NGNControllerSegueShowEditTask = @"ShowEditTask";
static NSString *const NGNControllerSegueShowDatePicking = @"ShowDatePicking";
static NSString *const NGNControllerSegueShowAddProject = @"ShowAddProject";
static NSString *const NGNControllerSegueShowAddTask = @"ShowAddTask";

#pragma mark - unwind segues identifiers
static NSString *const NGNControllerSegueUnwindToEditWithDone = @"UnwindToEditWithDone";
static NSString *const NGNControllerSegueUnwindToEditWithCancel = @"UnwindToEditWithCancel";

#pragma mark - notification names
static NSString *const NGNNotificationNameTaskChange = @"TaskChangeNotification";
static NSString *const NGNNotificationNameTaskAdd = @"TaskAddNotification";
static NSString *const NGNNotificationNameTaskListChange = @"TaskListChangeNotification";
static NSString *const NGNNotificationNameTaskListAdd = @"TaskListAddNotification";
static NSString *const NGNNotificationNameGlobalModelChange = @"GlobalModelChangeNotification";

@interface NGNConstants : NSObject

@end
