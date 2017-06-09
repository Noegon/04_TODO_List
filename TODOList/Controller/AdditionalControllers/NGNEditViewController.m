//
//  NGNEditViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNEditViewController.h"
#import "NGNDatePickingViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"
#import "NGNTask.h"

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
    if (!self.taskNameInsertTextField.text) {
        saveBarButton.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = saveBarButton;
    saveBarButton = nil;
    
    if (!self.entringTask) {
        NSString *stringfiedTodayDate = [NSDate ngn_formattedStringFromDate:[NSDate date]];
        [self.setDateButton setTitle:stringfiedTodayDate forState:UIControlStateNormal];
        self.notesInsertTextView.text = @"insert something here";
    }
    else {
        NSString *stringfiedTaskDate = [NSDate ngn_formattedStringFromDate:self.entringTask.startedAt];
        self.taskNameInsertTextField.text = self.entringTask.name;
        [self.setDateButton setTitle:stringfiedTaskDate forState:UIControlStateNormal];
        self.notesInsertTextView.text = self.entringTask.notes;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NGNNotificationNameTaskChange
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification) {
        NSDictionary *userInfo = notification.userInfo;
        NGNTask *task = userInfo[@"task"];
        [self.setDateButton setTitle:
        [NSDate ngn_formattedStringFromDate:task.startedAt] forState:UIControlStateNormal];
    }];
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    NGNTask *newTask;
    if (!self.entringTask) {
        NSInteger newTaskId = (rand() % INT_MAX);
        newTask = [[NGNTask alloc]initWithId:newTaskId
                                        name:self.taskNameInsertTextField.text
                                   startDate:[NSDate ngn_dateFromString:self.setDateButton.titleLabel.text]
                                       notes:self.notesInsertTextView.text];
    }
    else {
        newTask = self.entringTask;
        newTask.name = self.taskNameInsertTextField.text;
        newTask.notes = self.notesInsertTextView.text;
    }
    NSDictionary *userInfo = @{@"task": newTask};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setDateButtonTapped:(UIButton *)sender {
    NGNDatePickingViewController *datePickingViewController = [[NGNDatePickingViewController alloc]init];
    datePickingViewController.entringTask = self.entringTask;
    [self showViewController:datePickingViewController sender:sender];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.taskNameInsertTextField resignFirstResponder];
    [self.notesInsertTextView resignFirstResponder];
}

- (IBAction)taskNameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] ? YES : NO; //but I dont like ternary opereator anyway)
}

@end
