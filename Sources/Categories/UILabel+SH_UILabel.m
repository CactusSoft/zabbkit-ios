//
//  UILabel+SH_UILabel.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "UILabel+SH_UILabel.h"

@implementation UILabel (SH_UILabel)

+ (id)sh_labelWithFont:(UIFont *)font
             textColor:(UIColor *)textColor {
    return [self sh_labelWithFont:font
                        textColor:textColor
                    textAlignment:UITextAlignmentLeft];
}

+ (id)sh_labelWithFont:(UIFont *)font
             textColor:(UIColor *)textColor
         textAlignment:(UITextAlignment)textAlignment {
    UILabel *label = [[self class] new];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    return label;
}

+ (id)changeHeightLabel:(UILabel *)newLabel {
    UILabel *label = newLabel;

//Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, 9999);

    CGSize expectedLabelSize = [label.text sizeWithFont:label.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:label.lineBreakMode];
    CGFloat height;
//adjust the label the the new height.
    CGRect newFrame = label.bounds;
    height = expectedLabelSize.height - newFrame.size.height;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    return label;
}


@end
