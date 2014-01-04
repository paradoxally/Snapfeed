//
//  SNFTakePhotoViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/3/14.
//
//

#import "SNFCameraOverlayView.h"
#import "SNFTakePhotoViewController.h"

static const CGFloat kViewAlphaValue = 0.7;
static const CGFloat kCameraBarsHeight = 53;
static const CGFloat kiPhoneScreenWidth = 320;

@interface SNFTakePhotoViewController ()

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation SNFTakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
	self.captureManager = [[CaptureSessionManager alloc] init];
	[self.captureManager addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
    [self.captureManager addStillImageOutput];
	[self.captureManager addVideoPreviewLayer];
    
    UIView *cameraHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kiPhoneScreenWidth, kCameraBarsHeight)];
    cameraHeaderView.backgroundColor = [UIColor orangeColor];
    cameraHeaderView.alpha = kViewAlphaValue;
    
    UIView *cameraShutterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 140, kiPhoneScreenWidth, 140)];
    cameraShutterView.backgroundColor = [UIColor redColor];
    
    UIView *cameraControlsView = [[UIView alloc] initWithFrame:CGRectMake(0, cameraShutterView.frame.origin.y - 53, kiPhoneScreenWidth, kCameraBarsHeight)];
    cameraControlsView.backgroundColor = [UIColor greenColor];
    cameraControlsView.alpha = kViewAlphaValue;

    
	CGRect layerRect = CGRectMake(0, 0, kiPhoneScreenWidth, self.view.bounds.size.height - cameraShutterView.bounds.size.height);
    [self.captureManager.previewLayer setBounds:layerRect];
    [self.captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    [self.view.layer addSublayer:self.captureManager.previewLayer];
    
    [self.view addSubview:cameraHeaderView];
    [self.view addSubview:cameraShutterView];
    [self.view addSubview:cameraControlsView];
    
	[[self.captureManager captureSession] startRunning];
    
    
}

- (void)scanButtonPressed {
    [self.captureManager captureStillImage];
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum([self.captureManager stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
