//
//  NGNDatePickingViewController.m
//  TODOList
//
//  Created by Alex on 05.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDatePickingViewController.h"
#import "NGNConstants.h"
#import "NGNTask.h"

@interface NGNDatePickingViewController ()

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNDatePickingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation bar title is set
    self.navigationItem.title = @"Date picking";
    
    // save bar button is set and configured
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NGNControllerDoneButtonTitle
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(doneBarButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
    doneBarButton = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender {
//#warning uncompleted definition of "doneButtonTapped" method!!!
    if (!self.entringTask) {
        self.entringTask = [[NGNTask alloc]init];
    }
    self.entringTask.startedAt = self.datePicker.date;
    NSDictionary *userInfo = @{@"task": self.entringTask};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
