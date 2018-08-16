//
//  UIImageView+WebImage.m
//  ESWebImage
//
//  Created by 翟泉 on 2016/11/9.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "UIImageView+WebImage.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "DCWebImage.h"

@implementation UIImageView (WebImage)

+ (void)load; {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(layoutSubviews);
        SEL swizzledSelector = @selector(wi_layoutSubviews);
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        if (class_addMethod([self class],originalSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod([self class],swizzledSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
- (void)wi_layoutSubviews; {
    [self wi_layoutSubviews];
    
    if (self.wi_urlString) {
        [self imageWithURLString:self.wi_urlString Size:self.frame.size placeholderImage:self.wi_placeholderImage hasCanves:[self.wi_hasCanves boolValue] completed:self.wi_completedBlock];
        self.wi_urlString = NULL;
        self.wi_completedBlock = NULL;
        self.wi_placeholderImage = NULL;
        self.wi_hasCanves = NULL;
    }
}


- (void)imageWithURLString:(NSString *)URLString; {
    [self imageWithURLString:URLString completed:NULL];
}
- (void)imageWithURLString:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage{
    [self imageWithURLString:URLString placeholderImage:placeholderImage hasCanves:YES completed:NULL];
}
- (void)imageWithURLString:(NSString *)URLString completed:(ESWebImageCompleted)completedBlock; {
    [self imageWithURLString:URLString placeholderImage:NULL hasCanves:YES completed:completedBlock];
}

- (void)noCanvesImageWithURLString:(NSString *)URLString; {
    [self imageWithURLString:URLString placeholderImage:NULL hasCanves:NO completed:nil];
}
- (void)noCanvesImageWithURLString:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage{
    [self imageWithURLString:URLString placeholderImage:placeholderImage hasCanves:NO completed:NULL];
}
- (void)noCanvesImageWithURLString:(NSString *)URLString completed:(ESWebImageCompleted)completedBlock; {
    [self imageWithURLString:URLString placeholderImage:NULL hasCanves:NO completed:completedBlock];
}

- (void)imageWithURLString:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage hasCanves:(BOOL)hasCanves completed:(ESWebImageCompleted)completedBlock; {
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        [self layoutIfNeeded];
    }
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        self.wi_urlString = URLString;
        self.wi_placeholderImage = placeholderImage;
        self.wi_completedBlock = completedBlock;
        self.wi_hasCanves = @(hasCanves);
    }
    else {
        self.wi_urlString = NULL;
        self.wi_completedBlock = NULL;
        self.wi_placeholderImage = NULL;
        self.wi_hasCanves = NULL;
        [self imageWithURLString:URLString Size:self.frame.size placeholderImage:placeholderImage hasCanves:hasCanves completed:completedBlock];
    }
}



- (void)imageWithURLString:(NSString *)URLString Size:(CGSize)size hasCanves:(BOOL)hasCanves; {
    [self imageWithURLString:URLString Size:size  placeholderImage:NULL hasCanves:hasCanves completed:NULL];
}

- (void)noCanvesimageWithURLString:(NSString *)URLString hasCanves:(BOOL)hasCanves Size:(CGSize)size; {
    [self imageWithURLString:URLString Size:size placeholderImage:NULL hasCanves:hasCanves completed:NULL];
}

- (void)imageWithURLString:(NSString *)URLString Size:(CGSize)size hasCanves:(BOOL)hasCanves completed:(ESWebImageCompleted)completedBlock; {
    [self imageWithURLString:URLString Size:size placeholderImage:NULL hasCanves:hasCanves completed:completedBlock];
}
- (void)imageWithURLString:(NSString *)URLString Size:(CGSize)size placeholderImage:(UIImage *)placeholderImage hasCanves:(BOOL)hasCanves; {
    [self imageWithURLString:URLString Size:size placeholderImage:placeholderImage hasCanves:hasCanves completed:NULL];
}
- (void)imageWithURLString:(NSString *)URLString Size:(CGSize)size placeholderImage:(UIImage *)placeholderImage hasCanves:(BOOL)hasCanves completed:(ESWebImageCompleted)completedBlock; {
    if (!URLString || ![URLString isKindOfClass:[NSString class]]) {
        URLString = @"";
    }
    if (!placeholderImage) {
        placeholderImage = [DCWebImage placeholderWithSize:size];
    }
    
    [self sd_setImageWithURL:[DCWebImage URLWithURLString:URLString imageSize:size hasCanves:hasCanves] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        !completedBlock ?: completedBlock(image, error, imageURL);
    }];
}



- (void)productImageWithURLString:(NSString *)URLString {
    [self imageWithURLString:URLString Size:CGSizeZero hasCanves:YES completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, image.size.width, image.size.width));
        CGRect small = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        UIGraphicsBeginImageContext(small.size);
        UIImage *newImage = [UIImage imageWithCGImage:imageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        self.image = newImage;
    }];
}



- (NSString *)wi_urlString {
    return objc_getAssociatedObject(self, @"wi_urlString");
}
- (void)setWi_urlString:(NSString *)wi_urlString {
    objc_setAssociatedObject(self, @"wi_urlString", wi_urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (ESWebImageCompleted)wi_completedBlock {
    return objc_getAssociatedObject(self, @"wi_completedBlock");
}
- (void)setWi_completedBlock:(ESWebImageCompleted)wi_completedBlock {
    objc_setAssociatedObject(self, @"wi_completedBlock", wi_completedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSNumber *)wi_hasCanves {
    return objc_getAssociatedObject(self, @"wi_hasCanves");
}
- (void)setWi_hasCanves:(NSNumber *)wi_hasCanves {
    objc_setAssociatedObject(self, @"wi_hasCanves", wi_hasCanves, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (UIImage *)wi_placeholderImage {
    return objc_getAssociatedObject(self, @"wi_placeholderImage");
}
- (void)setWi_placeholderImage:(UIImage *)wi_placeholderImage {
    objc_setAssociatedObject(self, @"wi_placeholderImage", wi_placeholderImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end



