//
//  NGNDataSourceSingleton.m
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDataSourceSingleton.h"

@implementation NGNDataSourceSingleton

+ (instancetype)sharedInstance {
    static NGNDataSourceSingleton *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NGNDataSourceSingleton alloc] init];
    });
    return sharedInstance;
}

@end
