//
//  DCWebImage.h
//  DCWebImage
//
//  Created by quanzhizu on 2017/4/27.
//  Copyright © 2017年 quanzhizud2c. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCWebImage : NSObject
@property (strong, nonatomic) NSURL *baseURL;

+ (instancetype)shared;

+ (NSURL *)URLWithURLString:(NSString *)URLString imageSize:(CGSize)size;

+ (UIImage *)placeholderWithSize:(CGSize)size;

@end
