//
//  Themes.h
//  TinkoffChat
//
//  Created by Олег Самойлов on 17/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Themes : NSObject {
    UIColor *_theme1, *_theme2, *_theme3;
}

- (instancetype)initWithTheme1:(UIColor *)theme1
                        theme2:(UIColor *)theme2
                        theme3:(UIColor *)theme3;
- (void)dealloc;

@property (nonatomic, retain) UIColor *theme1;
@property (nonatomic, retain) UIColor *theme2;
@property (nonatomic, retain) UIColor *theme3;

@end
