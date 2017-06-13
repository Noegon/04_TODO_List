//
//  NGNConstants.h
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - controller constants
static NSString *const NGNControllerTaskCellIdentifier = @"NGNTaskCell";
static NSString *const NGNControllerDateFormat = @"dd/LL/yyyy";

#pragma mark - some view titles
static NSString *const NGNControllerSaveButtonTitle = @"Save";
static NSString *const NGNControllerEditButtonTitle = @"Edit";
static NSString *const NGNControllerDoneButtonTitle = @"Done";

#pragma mark - segues identifiers
static NSString *const NGNControllerSegueShowTaskDetail = @"ShowTaskDetail";

#pragma mark - notification names
static NSString *const NGNNotificationNameTaskChange = @"TaskChangeNotification";

@interface NGNConstants : NSObject

@end
