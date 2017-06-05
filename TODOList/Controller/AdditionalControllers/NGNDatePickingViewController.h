//
//  NGNDatePickingViewController.h
//  TODOList
//
//  Created by Alex on 05.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNDatePickingViewController;

@protocol NGNDatePickingViewControllerDelegate <NSObject>

@optional
- (void)datePickingViewController:(NGNDatePickingViewController *)datePickingViewController
                     didChangedDate:(NSDate *)date;

@end

@interface NGNDatePickingViewController : UIViewController

@property (nonatomic, weak) id<NGNDatePickingViewControllerDelegate> delegate;

@end
