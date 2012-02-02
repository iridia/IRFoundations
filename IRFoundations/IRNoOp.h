//
//  IRNoOp.h
//  Milk
//
//  Created by Evadne Wu on 1/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IRNoOp : NSObject <NSCoding, NSCopying>

+ (IRNoOp *) noOp NS_RETURNS_NOT_RETAINED;

@end
