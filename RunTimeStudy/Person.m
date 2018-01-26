//
//  Person.m
//  UITableViewDeleage
//
//  Created by LeoLai on 2018/1/25.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>
@implementation Person

+ (void)load {
//    [self ivarList];
//    [self propertyList];
//    [self methodList];
    
//
//    [p say:@"GG"];
//    [self exchangeMethod];
    [self dynamicClass];
    Person *p = [[Person alloc] init];
//    p.name = @"lailongwei";
//    p->des = @"Person描述";
//    NSLog(@"description : %@", [p performSelector:@selector(description)]);
////    NSLog(@"%@", [p description]) ;
//    NSLog(@"des : %@", [p performSelector:@selector(des)]);
}

- (void)say:(NSString *)something {
    NSLog(@"say: %@", something);
}

- (NSString *)des {
    return des;
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

+ (void)methodList {
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(self, &count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSMutableString *mStr = [[NSMutableString alloc] init];
        SEL name = method_getName(method);
        NSString *nameStr = NSStringFromSelector(name);
        [mStr appendFormat:@"sel name : %@", nameStr];
        IMP imp = method_getImplementation(method);
        const char *typeEncode = method_getTypeEncoding(method);
        [mStr appendFormat:@" typeEncode : %s", typeEncode];
        NSInteger argumentCount = method_getNumberOfArguments(method);
        char *returnType = method_copyReturnType(method);
        [mStr appendFormat:@" returnType : %s", returnType];
        for (int j = 0; j < argumentCount; j++) {
            char *argumentType = method_copyArgumentType(method, j);
            [mStr appendFormat:@" argumentType %d %s", j, argumentType];
        }
        if ([nameStr isEqualToString:@"say:"]) {
            __block IMP originalIMP = NULL;
            void (^saySomething)(Person * , NSString *) = ^(Person *self, NSString *tosay) {
                NSLog(@"lailongwei say %@", tosay);
                void(*originalIMPTemp)(Person *, SEL sel, NSString *) = originalIMP;
                if (originalIMPTemp) {
                    originalIMPTemp(self, name, tosay);
                }
                
            };
            IMP toImp = imp_implementationWithBlock(saySomething);
            originalIMP = method_setImplementation(method, toImp);
        }

        NSLog(@"%@", nameStr);
        
    }
}

+ (void)dynamicAddMethod {
    SEL descriptionSEL = NSSelectorFromString(@"description");
    Method descriptionMethod = class_getInstanceMethod(self, descriptionSEL);
    // 父类有的方法，会直接override
    BOOL add = class_addMethod(self, descriptionSEL, descriptionMethodIMP, "@:@");
    if (add) {
        NSLog(@"%@", @"添加成功");
    } else {
        NSLog(@"%@", @"添加失败");
    }
}

+ (void)dynamicAddMethod1 {
    SEL sayHelloSEL = NSSelectorFromString(@"sayHello");
    void(^sayHelloBlock)(Person *, SEL) = ^(Person *self, SEL sel) {
        NSLog(@"hello world");
    };
    IMP imp = imp_implementationWithBlock(sayHelloBlock);
    // 自己，父类没有的方法，会添加
    class_addMethod(self, sayHelloSEL, imp, "v:");
}

+ (void)dynamicAddMethod2 {
    SEL sayHelloSEL = NSSelectorFromString(@"des");
    __block IMP originalIMP = NULL;
    NSString *(^sayHelloBlock)(Person *, SEL) = ^NSString *(Person *self, SEL sel) {
        if (originalIMP) {
            NSString *originalStr = ((NSString *(*)(Person *, SEL))originalIMP)(self, sel);
            return [NSString stringWithFormat:@"hello world2 _ %@", originalStr];
        } else {
            return @"hello world2";
        }
    };
    IMP imp = imp_implementationWithBlock(sayHelloBlock);
    // 类本身有实现的时候，会添加失败
    BOOL add = class_addMethod(self, sayHelloSEL, imp, "@:");
    if (add) {
        NSLog(@"%@", @"添加成功");
    } else {
        NSLog(@"%@", @"添加失败");
        Method method = class_getInstanceMethod(self, sayHelloSEL);
        originalIMP = method_setImplementation(method, imp);
    }
}

+ (void)exchangeMethod {
    SEL description = @selector(description);
    SEL des = @selector(des);
    Method descriptionMethod = class_getInstanceMethod(self, description);
    Method desMethod = class_getInstanceMethod(self, des);
    method_exchangeImplementations(descriptionMethod, desMethod);
}

NSString *descriptionMethodIMP(Person *self, SEL sel) {
    return [NSString stringWithFormat:@"name == %@", self.name];
}

#pragma mark - Class

+ (void)dynamicClass {
    Class Man = objc_allocateClassPair(self, "Man", 0);
    __block IMP originalIMP = NULL;
    SEL forwardSEL = @selector(forwardInvocation:);
    void(^forwardInvocationBlock)(id, NSInvocation *) = ^(id self, NSInvocation *invocation) {
        NSString *aliasSetNameSELStr = [NSString stringWithFormat:@"alias_%@", NSStringFromSelector(invocation.selector)];
        SEL aliasSetNameSEL = NSSelectorFromString(aliasSetNameSELStr);
        if ([self respondsToSelector:aliasSetNameSEL]) {
            invocation.selector = aliasSetNameSEL;
            [invocation invoke];
        } else {
            if (originalIMP) {
                ((void(*)(id, SEL,  NSInvocation *))originalIMP)(self, forwardSEL, invocation);
            } else {
                [self doesNotRecognizeSelector:invocation.selector];
            }
        }
        NSLog(@"调用了 %@", NSStringFromSelector(invocation.selector));
    };
    IMP blockIMP = imp_implementationWithBlock(forwardInvocationBlock);
    class_addMethod(Man, @selector(forwardInvocation:), blockIMP, "v:@");
    
    SEL setNameSEL = @selector(setName:);
    Method setNameMethod = class_getInstanceMethod(Man, setNameSEL);
    IMP originalSetNameIMP = method_getImplementation(setNameMethod);
    
    NSString *aliasSetNameSELStr = [NSString stringWithFormat:@"alias_%@", NSStringFromSelector(setNameSEL)];
    SEL aliasSetNameSEL = NSSelectorFromString(aliasSetNameSELStr);
    if (!aliasSetNameSEL) {
        sel_registerName(aliasSetNameSELStr.UTF8String);
    }
    BOOL add = class_addMethod(Man, aliasSetNameSEL, originalSetNameIMP, method_getTypeEncoding(setNameMethod));
    if (add) {
        NSLog(@"添加成功");
    }
    
    method_setImplementation(setNameMethod, _objc_msgForward);
    
    objc_registerClassPair(Man);
    
    Person *person = [[Person alloc] init];
    object_setClass(person, Man);
    person.name = @"lailongwei";
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
}

@end
