//
//  NGNDatePickingViewController.m
//  TODOList
//
//  Created by Alex on 05.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDatePickingViewController.h"
#import "NSDate+NGNDateToStringConverter.h"

@interface NGNDatePickingViewController ()

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

- (IBAction)pickerDidChangeDateValue:(UIDatePicker *)sender;

@end

@implementation NGNDatePickingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateLabel.text = [NSDate ngn_formattedStringFromDate: self.datePicker.date];
}

- (IBAction)pickerDidChangeDateValue:(UIDatePicker *)sender {
    self.dateLabel.text = [NSDate ngn_formattedStringFromDate:sender.date];
}

@end
