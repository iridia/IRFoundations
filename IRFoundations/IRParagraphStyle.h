//
//  IRParagraphStyle.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface IRParagraphStyle : NSObject

- (id) initWithSpecifiers:(NSArray *)specifiers;

- (CTParagraphStyleRef) copyCTParagraphStyle;

@end


@interface IRParagraphStyleSetting : NSObject

- (id) initWithSpecifier:(CTParagraphStyleSpecifier)aSpecifier valueSize:(size_t)size value:(const void *)value;

- (CTParagraphStyleSetting) ctParagraphStyleSetting;

@end
