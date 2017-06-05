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
#import "NGNTask.h"

@interface NGNEditViewController () <NGNDatePickingViewControllerDelegate>

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
    srand((unsigned int)time(NULL));
    
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
    
    if (![NGNDateFormatHelper dateFromString:self.setDateButton.titleLabel.text]) {
        self.setDateButton.titleLabel.text = [NGNDateFormatHelper formattedStringFromDate:[NSDate date]];
    }
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    // here we creating or updating task in taskList and sending changes to InboxViewController
    id<NGNEditViewControllerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(editViewController:didSavedTask:)]) {
        NSString *newTaskId = [NSString stringWithFormat:@"%d", (rand() % INT_MAX)];
        NGNTask *newTask = [[NGNTask alloc]initWithId:newTaskId
                                                 name:self.taskNameInsertTextField.text
                                            startDate:[NGNDateFormatHelper dateFromString:self.setDateButton.titleLabel.text]
                                                notes:self.notesInsertTextView.text];
        [strongDelegate editViewController:self didSavedTask:newTask];
    }
    strongDelegate = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)setDateButtonTapped:(UIButton *)sender {
    //here we change title on setDateButton by datePicker from NGNDatePickingViewController
    NGNDatePickingViewController *datePickingViewController = [[NGNDatePickingViewController alloc]init];
    datePickingViewController.delegate = self;
    [self showViewController:datePickingViewController sender:sender];
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

#pragma mark - delegate methods

- (void)datePickingViewController:(NGNDatePickingViewController *)datePickingViewController
                   didChangedDate:(NSDate *)date {
    self.setDateButton.titleLabel.text = [NGNDateFormatHelper formattedStringFromDate:date];
}

@end
