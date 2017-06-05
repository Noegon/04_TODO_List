//
//  NGNEditViewController.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNTask;
@class NGNEditViewController;

@protocol NGNEditViewControllerDelegate <NSObject>

@optional
- (void)editViewController:(NGNEditViewController *)editViewController
              didSavedTask:(NGNTask *)task;

@end

@interface NGNEditViewController : UIViewController

@property (nonatomic, weak) id<NGNEditViewControllerDelegate> delegate;

@end
