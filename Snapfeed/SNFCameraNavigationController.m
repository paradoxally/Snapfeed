//
//  SNFCameraNavigationController.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/8/14.
//
//

#import "SNFCameraNavigationController.h"
#import "SNFTakePhotoViewController.h"
#import "SNFCameraNavigationBar.h"

@interface SNFCameraNavigationController ()

@end

@implementation SNFCameraNavigationController

+ (UIImage *)emptyImageWithSize:(CGSize)size andBackgroundColor:(UIColor*)color
{
    CGRect frameRect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, color.CGColor); //image frame color
    CGContextFillRect(ctx, frameRect);
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor clearColor];
    UIImage *transparentImage = [SNFCameraNavigationController emptyImageWithSize:CGSizeMake(self.navigationBar.frame.size.width, 1) andBackgroundColor:[UIColor clearColor]];
    [self.navigationBar setBackgroundImage:transparentImage forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = transparentImage;
    
    SNFCameraNavigationBar *navigationBar = [[SNFCameraNavigationBar alloc] initWithFrame:
                                    CGRectMake(0, 0, self.navigationBar.frame.size.width, 53)];
    [self.navigationBar insertSubview:navigationBar atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
