//
//  NGNContainable.h
//  TODOList
//
//  Created by Alex on 25.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNStoreable.h"

@protocol NGNContainable <NSObject>

@required
- (id<NGNStoreable>)entityById:(NSInteger)entityId;
- (void)addEntity:(id<NGNStoreable>)entity;
- (void)pushEntity:(id<NGNStoreable>)entity;
- (void)removeEntity:(id<NGNStoreable>)entity;
- (void)updateEntity:(id<NGNStoreable>)entity;
- (void)removeEntityById:(NSInteger)entityId;
- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex;
- (void)insertEntity:(id<NGNStoreable>)entity atIndex:(NSUInteger)index;
- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

@end
