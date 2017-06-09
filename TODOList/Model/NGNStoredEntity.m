//
//  NGNStoredEntity.m
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNStoredEntity.h"

@implementation NGNStoredEntity

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name {
    if (self = [super init]) {
        _entityId = entityId;
        _name = name;
    }
    return self;
}

@end
