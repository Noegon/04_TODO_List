//
//  NGNEditViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNEditViewController.h"
#import "NGNDatePickingViewController.h"
#import "NGNDateFormatHelper.h"
#import "NGNConstants.h"

@interface NGNEditViewController ()

@property (strong, nonatomic) IBOutlet UITextField *taskNameInsertTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesInsertTextView;
@property (strong, nonatomic) IBOutlet UIButton *setDateButton;

- (IBAction)taskNameChanged:(UITextField *)sender;
- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)setDateButtonTapped:(UIButton *)sender;


@end

@implementation NGNEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // taskNameInsertTextField configured
    [self.taskNameInsertTextField becomeFirstResponder];
    
    // navigation bar title is set
    self.navigationItem.title = @"Edit task";
    
    // save bar button is set and configured
    UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:NGNControllerSaveButtonTitle
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(saveBarButtonTapped:)];
    if ([self.taskNameInsertTextField.text isEqualToString:@""]) {
        saveBarButton.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = saveBarButton;
    saveBarButton = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // setDate button configured
    if ([self.setDateButton.titleLabel.text isEqualToString:@"Set Date"]) {
        NSString *tmpDateString = [NGNDateFormatHelper formattedStringFromDate:[NSDate date]];
        NSLog(@"%@", tmpDateString);
        self.setDateButton.titleLabel.text = tmpDateString;
    }
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
#warning uncompleted declaration of "saveBarButtonTapped" method!!!
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)setDateButtonTapped:(UIButton *)sender {
#warning uncompleted declaration of "setDateButtonTapped" method!!!
    NGNDatePickingViewController *datePicingViewController = [[NGNDatePickingViewController alloc]init];
    [self showViewController:datePicingViewController sender:sender];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.taskNameInsertTextField resignFirstResponder];
    [self.notesInsertTextView resignFirstResponder];
}

- (IBAction)taskNameChanged:(UITextField *)sender {
    if ([sender.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
@end
