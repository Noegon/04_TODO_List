//
//  NGNDeletionConfirmViewController.m
//  TODOList
//
//  Created by Alex on 14.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDeletionConfirmViewController.h"

@interface NGNDeletionConfirmViewController ()

#pragma mark - main methods

- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;

#pragma mark - delegate methods
- (void)sendMessageForDelegate:(BOOL)message;

@end

@implementation NGNDeletionConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
}

- (IBAction)yesButtonTapped:(UIButton *)sender {
    [self sendMessageForDelegate:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)noButtonTapped:(UIButton *)sender {
    [self sendMessageForDelegate:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMessageForDelegate:(BOOL)message {
    if ([self.delegate respondsToSelector:@selector(deletionController:didSendResult:toTableView:atIndexPath:)]) {
        [self.delegate deletionController:self didSendResult:message
                              toTableView:self.entringTableView
                              atIndexPath:self.entringIndexPath];
    }
}

@end
