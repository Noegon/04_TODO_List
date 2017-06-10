//
//  NGNGenericEntityContainer.h
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNStoreable.h"

@class NGNStoredEntity;

@interface NGNCommonEntityContainer : NSObject

@property (strong, nonatomic, readonly) NSArray<id<NGNStoreable>> *entityCollection;

- (id<NGNStoreable>)entityById:(NSInteger)entityId;
- (void)addEntity:(id<NGNStoreable>)entity;
- (void)removeEntity:(id<NGNStoreable>)entity;
- (void)updateEntity:(id<NGNStoreable>)entity;
- (void)removeEntityById:(NSInteger)entityId;
- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

@end
