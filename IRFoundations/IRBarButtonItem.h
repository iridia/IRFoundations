//
//  IRBarButtonItem.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IRBarButtonItem : UIBarButtonItem

+ (id) itemWithCustomView:(UIView *)aView;

+ (id) itemWithButton:(UIButton *)aButton wiredAction:(void(^)(UIButton *senderButton, IRBarButtonItem *senderItem))aBlock;
- (IBAction) handleCustomButtonAction:(id)sender; // button will be wired to the item, which runs the block

+ (id) itemWithSystemItem:(UIBarButtonSystemItem)aSystemItem wiredAction:(void(^)(IRBarButtonItem *senderItem))aBlock;

@property (nonatomic, readwrite, copy) void (^block)();

@end
