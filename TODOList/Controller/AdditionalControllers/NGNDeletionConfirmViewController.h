//
//  NGNDeletionConfirmViewController.h
//  TODOList
//
//  Created by Alex on 14.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNDeletionConfirmViewController;

//definition of delegate protocol and methods
@protocol NGNDeletionConfirmViewControllerDelegate <NSObject>

@optional
- (void)deletionController:(NGNDeletionConfirmViewController *)deletionController
             didSendResult:(BOOL)result
               toTableView:(UITableView *)tableView
               atIndexPath:(NSIndexPath *)indexPath;

@end;


@interface NGNDeletionConfirmViewController : UIViewController

@property (weak, nonatomic) id<NGNDeletionConfirmViewControllerDelegate> delegate;
@property (strong, nonatomic) UITableView *entringTableView;
@property (strong, nonatomic) NSIndexPath *entringIndexPath;

@end
