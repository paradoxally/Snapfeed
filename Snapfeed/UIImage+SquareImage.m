//
//  UIImage+SquareImage.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/9/14.
//
//

#import "UIImage+SquareImage.h"

@implementation UIImage (SquareImage)

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    // Make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    // Figure out if the picture is landscape or portrait, then
    // calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/1.598, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/1.598);
    }
    
    DDLogVerbose(@"Delta: %f", delta);
    DDLogVerbose(@"Ratio: %f", ratio);
    DDLogVerbose(@"Offset: (%f, %f)", offset.x, offset.y);
    
    // Make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta * 1.272);
    DDLogVerbose(@"%@: Image crop rect: (%f, %f, %f, %f)", THIS_FILE, clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
    
    
    // Start a new context, with scale factor 0.0 so retina displays get
    // high quality image
    DDLogVerbose(@"%@: Going to resize image now", THIS_FILE);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    DDLogVerbose(@"%@: Resize done!", THIS_FILE);
    return newImage;
}


@end
