//
//  SomaProxy.h
//  SomaKit
//
//  Created by Anton on 30.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SomaProxy : NSObject

- (void)_bindForwardObject:(id)forwardObject withRetain:(BOOL)retain;

@end