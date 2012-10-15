//
//  UIResponder+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (IRAdditions)

+ (id) instanceFromNib;

@property (nonatomic, readwrite, weak) IBOutlet UIResponder *ir_previousResponder;
@property (nonatomic, readwrite, weak) IBOutlet UIResponder *ir_nextResponder;

@end
