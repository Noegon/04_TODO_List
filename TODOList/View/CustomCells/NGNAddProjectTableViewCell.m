//
//  NGNAddProjectTableViewCell.m
//  TODOList
//
//  Created by Alex on 18.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNAddProjectTableViewCell.h"

@implementation NGNAddProjectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated]; //do not call if i don't need animation
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self configureConstraints];
}

- (void)configureConstraints {
    // This is where the cell subviews are laid out.
}

@end
