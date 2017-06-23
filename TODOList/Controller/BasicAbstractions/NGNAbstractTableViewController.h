//
//  NGNAbstractTableViewController.h
//  TODOList
//
//  Created by Alex on 17.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGNStoreable.h"

@interface NGNAbstractTableViewController : UITableViewController

@property (strong, nonatomic) id<NSObject> taskChangeNotification;
@property (strong, nonatomic) id<NSObject> taskAddNotification;
@property (strong, nonatomic) id<NSObject> taskListChangeNotification;
@property (strong, nonatomic) id<NSObject> taskListAddNotification;
@property (strong, nonatomic) id<NSObject> globalModelChangeNotification;

#pragma mark - additional handling methods

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;
- (void)performTaskDeleteConfirmationDialogueAtTableView:(UITableView *)tableView
                                             atIndexPath:(NSIndexPath *)indexPath
                                       withStoreableItem:(id<NGNStoreable>)storeableItem;
#pragma mark - gestures handling

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;

@end
