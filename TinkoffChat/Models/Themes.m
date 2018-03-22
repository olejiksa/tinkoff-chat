//
//  Themes.m
//  TinkoffChat
//
//  Created by Олег Самойлов on 20/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

#import "Themes.h"

@implementation Themes

- (instancetype)initWithTheme1:(UIColor *)theme1
                        theme2:(UIColor *)theme2
                        theme3:(UIColor *)theme3 {
    if (self = [super init]) {
        self.theme1 = theme1;
        self.theme2 = theme2;
        self.theme3 = theme3;
    }
    
    return self;
}

- (void)dealloc {
    [_theme1 release];
    _theme1 = nil;
    
    [_theme2 release];
    _theme2 = nil;
    
    [_theme3 release];
    _theme3 = nil;
    
    [super dealloc];
}

- (UIColor *)theme1 {
    return _theme1;
}

- (void)setTheme1:(UIColor *)theme1 {
    if (_theme1 != theme1) {
        [_theme1 release];
        _theme1 = [theme1 retain];
    }
}

- (UIColor *)theme2 {
    return _theme2;
}

- (void)setTheme2:(UIColor *)theme2 {
    if (_theme2 != theme2) {
        [_theme2 release];
        _theme2 = [theme2 retain];
    }
}

- (UIColor *)theme3 {
    return _theme3;
}

- (void)setTheme3:(UIColor *)theme3 {
    if (_theme3 != theme3) {
        [_theme3 release];
        _theme3 = [theme3 retain];
    }
}

@end
