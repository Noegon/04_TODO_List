//
//  NGNEditTaskListViewController.m
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNAddProjectViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNConstants.h"
#import "NGNTaskService.h"

@interface NGNAddProjectViewController ()

@property (strong, nonatomic) NGNTaskList *entringTaskList;
@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)projectNameValueChanged:(UITextField *)sender;

@end

@implementation NGNAddProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand((unsigned int)time(NULL));
    NSInteger newTaskListId = (rand() % INT_MAX);
    
    self.entringTaskList = [[NGNTaskList alloc] initWithId:newTaskListId name:@""];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.projectNameTextField becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    self.entringTaskList.name = self.projectNameTextField.text;
    [[NGNTaskService sharedInstance] addEntity:self.entringTaskList];
    NSDictionary *userInfo = @{@"taskList": self.entringTaskList};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListAdd
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)projectNameValueChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] ? YES : NO;
}

@end
