//
//  NGNDatePickingViewController.m
//  TODOList
//
//  Created by Alex on 05.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDatePickingViewController.h"
#import "NGNConstants.h"

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
    // here we changing date and sending to delegate changed value
    id<NGNDatePickingViewControllerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(datePickingViewController:didChangedDate:)]) {
        [strongDelegate datePickingViewController:self didChangedDate:self.datePicker.date];
    }
    strongDelegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
