//
//  Person.h
//  UITableViewDeleage
//
//  Created by LeoLai on 2018/1/25.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface Person : NSObject
{
    NSString *des;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
