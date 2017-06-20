//
//  NGNStoredEntity.h
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNStoreable.h"

@interface NGNStoredEntity : NSObject <NGNStoreable>

@property (assign, nonatomic) NSInteger entityId;
@property (copy, nonatomic) NSString *name;

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name;

@end
