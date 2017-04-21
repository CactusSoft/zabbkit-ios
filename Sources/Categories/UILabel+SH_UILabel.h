//
//  UILabel+SH_UILabel.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (SH_UILabel)

+ (id)sh_labelWithFont:(UIFont *)font
             textColor:(UIColor *)textColor;

+ (id)sh_labelWithFont:(UIFont *)font
             textColor:(UIColor *)textColor
         textAlignment:(UITextAlignment)textAlignment;

+ (id)changeHeightLabel:(UILabel *)newLabel;

@end
