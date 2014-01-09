//
//  UIImage+SquareImage.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/9/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (SquareImage)

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
