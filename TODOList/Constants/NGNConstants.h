//
//  NGNConstants.h
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define foo4random() (arc4random() % ((unsigned)RAND_MAX + 1))
//checking system version
#define SYSTEM_VERSION_EQUAL_TO(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

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

#pragma mark - segues identifiers
static NSString *const NGNControllerSegueShowTaskDetail = @"ShowTaskDetail";
static NSString *const NGNControllerSegueShowTaskListDetail = @"ShowTaskListDetail";
static NSString *const NGNControllerSegueShowEditTask = @"ShowEditTask";
static NSString *const NGNControllerSegueShowDatePicking = @"ShowDatePicking";
static NSString *const NGNControllerSegueShowAddProject = @"ShowAddProject";
static NSString *const NGNControllerSegueShowAddTask = @"ShowAddTask";

#pragma mark - controllers identifiers
static NSString *const NGNControllerIdentifierEditTask = @"EditTask";

#pragma mark - unwind segues identifiers
static NSString *const NGNControllerSegueUnwindToEditWithDone = @"UnwindToEditWithDone";
static NSString *const NGNControllerSegueUnwindToEditWithCancel = @"UnwindToEditWithCancel";

#pragma mark - notification names
static NSString *const NGNNotificationNameTaskChange = @"TaskChangeNotification";
static NSString *const NGNNotificationNameTaskAdd = @"TaskAddNotification";
static NSString *const NGNNotificationNameTaskListChange = @"TaskListChangeNotification";
static NSString *const NGNNotificationNameTaskListAdd = @"TaskListAddNotification";
static NSString *const NGNNotificationNameGlobalModelChange = @"GlobalModelChangeNotification";

#pragma mark - notification names
static NSString *const NGNNotificationRequestIDTaskTime = @"TaskTimeHasCome";

@interface NGNConstants : NSObject

@end
