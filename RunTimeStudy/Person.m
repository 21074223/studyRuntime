//
//  Person.m
//  UITableViewDeleage
//
//  Created by LeoLai on 2018/1/25.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (void)load {
    [self ivarList];
//    [self propertyList];
}

+ (void)ivarList {
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = *(ivarList + i);
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        printf("name:%s  type:%s\n", name, type);
    }
    free(ivarList);
    
}

+ (void)propertyList {
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(self, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = *(propertyList + i);
        const char *name = property_getName(property);
        const char *des = property_getAttributes(property);
        printf("name:%s  des:%s\n", name, des);
        
        unsigned int attrCount = 0;
        objc_property_attribute_t *attrList = property_copyAttributeList(property, &attrCount);
        for (int j = 0; j < attrCount; j++) {
            objc_property_attribute_t attr = *(attrList + j);
            const char *attrName = attr.name;
            const char *attrValue = attr.value;
            if (attrName && attrValue) {
                printf("attrName:%s  attrValue:%s\n", attrName, attrValue);
            } else if (attrName) {
                printf("attrName:%s  attrValue:NULL \n", attrName);
            }

        }
        free(attrList);
    }
    free(propertyList);
    
//name:name  des:T@"NSString",&,N,V_name
//attrName:T  attrValue:@"NSString"           //属性类型
//attrName:&  attrValue:                      //编码类型 C(copy) &(strong) W(weak)
//attrName:N  attrValue:                      //非/原子性   N(nonatomic)
//attrName:V  attrValue:_name                 //变量名称 V
//name:age  des:Tq,N,V_age
//attrName:T  attrValue:q
//attrName:N  attrValue:
//attrName:V  attrValue:_age
}

@end
