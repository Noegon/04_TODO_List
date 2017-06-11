//
//  NGNEditTaskViewController.h
//  TODOList
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNTask;

@interface NGNEditTaskViewController : UITableViewController

@property (strong, nonatomic) NGNTask *entringTask;

@end
