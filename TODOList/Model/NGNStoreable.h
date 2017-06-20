//
//  NGNStoreable.h
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NGNStoreable <NSObject>

@required
- (NSInteger)entityId;
- (NSString *)name;
@optional
- (BOOL)isCompleted;

@end
