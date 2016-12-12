//
//  SomaProxy.m
//  SomaKit
//
//  Created by Anton on 30.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

#import "SomaProxy.h"

@interface SomaProxy ()

@property (strong, nonatomic) id retainForwardObject;

@end

@implementation SomaProxy

- (void)setForwardObject:(id)forwardObject {
    [self setForwardObject:forwardObject withRetain:false];
}

- (void)setForwardObject:(id)forwardObject withRetain:(BOOL)retain {
    _forwardObject = forwardObject;
    self.retainForwardObject = retain ? forwardObject : nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.forwardObject respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.forwardObject];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.forwardObject respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [super conformsToProtocol:aProtocol] || [self.forwardObject conformsToProtocol:aProtocol];
}

@end
