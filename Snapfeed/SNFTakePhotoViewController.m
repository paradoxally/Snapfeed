//
//  SNFTakePhotoViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/3/14.
//
//

#import "SNFCameraOverlayView.h"
#import "SNFAppDelegate.h"
#import "SNFCameraControlButton.h"
#import "UIImage+SquareImage.h"
#import "SNFPostingPhotoViewController.h"
#import "SNFTakePhotoViewController.h"
#import <CoreMotion/CoreMotion.h>

NSString *const flashModeChangedNotificationName = @"flashModeChangedNotification";

static const CGFloat kViewAlphaValue = 0.9;
static const CGFloat kCameraBarsHeight = 53;
static const CGFloat kiPhoneScreenWidth = 320;
static const CGFloat kiPhoneShutterViewHeight = 118;
static const CGFloat kiPhone4InchShutterViewHeight = 140;
static const CGSize kImageSize = {612, 612};

@interface SNFTakePhotoViewController ()

@property (nonatomic) CGRect imageCropRect;

@property (nonatomic, strong) UIImage *croppedImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *leftHelperLine;
@property (nonatomic, strong) UIView *rightHelperLine;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) SNFCameraControlButton *flashButton;
@property (nonatomic) BOOL isLevelVisible;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation SNFTakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.captureManager = [[CaptureSessionManager alloc] init];
	[self.captureManager addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
    [self.captureManager addStillImageOutput];
	[self.captureManager addVideoPreviewLayer];
    
    UIView *cameraShutterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (IS_IPHONE_4_INCH ? kiPhone4InchShutterViewHeight : kiPhoneShutterViewHeight), kiPhoneScreenWidth, (IS_IPHONE_4_INCH ? kiPhone4InchShutterViewHeight : kiPhoneShutterViewHeight))];
    cameraShutterView.backgroundColor = [UIColor flatDarkBlackColor];
    
    UIView *cameraControlsView = [[UIView alloc] initWithFrame:CGRectMake(0, cameraShutterView.frame.origin.y - kCameraBarsHeight, kiPhoneScreenWidth, kCameraBarsHeight)];
    cameraControlsView.backgroundColor = [UIColor flatBlackColor];
    cameraControlsView.alpha = kViewAlphaValue;
    
    UIImage *gridImage = [UIImage imageNamed:@"grid"];
    SNFCameraControlButton *gridButton = [[SNFCameraControlButton alloc] initWithFrame:
                                          CGRectMake(30, 0, gridImage.size.width, kCameraBarsHeight)];
    [gridButton setImage:gridImage forState:UIControlStateNormal];
    [gridButton addTarget:self action:@selector(toggleLevel:) forControlEvents:UIControlEventTouchUpInside];
    [cameraControlsView addSubview:gridButton];
    
    UIImage *switchCameraImage = [UIImage imageNamed:@"switch-camera"];
    SNFCameraControlButton *switchCameraButton = [[SNFCameraControlButton alloc] initWithFrame:
                                          CGRectMake(105, -1, switchCameraImage.size.width, kCameraBarsHeight)];
    [switchCameraButton setImage:switchCameraImage forState:UIControlStateNormal];
    [switchCameraButton addTarget:self action:@selector(switchCameras:) forControlEvents:UIControlEventTouchUpInside];
    [cameraControlsView addSubview:switchCameraButton];
    
    self.flashButton = [[SNFCameraControlButton alloc] initWithFrame:
                                                  CGRectMake(190, 0, 40, kCameraBarsHeight)];
    [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
    [cameraControlsView addSubview:self.flashButton];
    
    /*SNFCameraControlButton *flashButton2 = [[SNFCameraControlButton alloc] initWithFrame:
                                           CGRectMake(265, 0, noFlashImage.size.width, kCameraBarsHeight)];
    [flashButton2 setImage:noFlashImage forState:UIControlStateNormal];
    [cameraControlsView addSubview:flashButton2];*/
    
	CGRect layerRect = CGRectMake(0, 0, kiPhoneScreenWidth, self.view.bounds.size.height - cameraShutterView.bounds.size.height);
    [self.captureManager.previewLayer setBounds:layerRect];
    [self.captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    [self.view.layer addSublayer:self.captureManager.previewLayer];
    
    UIImage *shutterImage = [UIImage imageNamed:@"shutter"];
    UIButton *shutterButton = [[UIButton alloc] initWithFrame:CGRectMake(160 - shutterImage.size.width / 2, cameraShutterView.frame.size.height / 2 - shutterImage.size.height / 2, shutterImage.size.width, shutterImage.size.height)];
    [shutterButton setImage:shutterImage forState:UIControlStateNormal];
    [shutterButton addTarget:self action:@selector(shutterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cameraShutterView addSubview:shutterButton];
    
    self.imageCropRect = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 9, 320, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - cameraShutterView.frame.size.height - cameraControlsView.frame.size.height - 9);
    
    [self addCloseButton];
    [self.view addSubview:cameraShutterView];
    [self.view addSubview:cameraControlsView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flashModeToggled:)
                                                 name:flashModeChangedNotificationName
                                               object:nil];
    
    [[self.captureManager captureSession] startRunning];
}

#define kFilteringFactor 0.175

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.motionManager isAccelerometerActive]) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

- (void)toggleLevel:(id)sender {
    if (self.isLevelVisible) {
        // hide level and stop accelerometer updates
        self.isLevelVisible = NO;
        [self.leftHelperLine removeFromSuperview];
        [self.rightHelperLine removeFromSuperview];
        [self.lineView removeFromSuperview];
        if ([self.motionManager isAccelerometerActive]) {
            [self.motionManager stopAccelerometerUpdates];
        }
    } else {
        self.isLevelVisible = YES;
        self.leftHelperLine = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 70, 1)];
        self.leftHelperLine.backgroundColor = [UIColor whiteColor];
        self.rightHelperLine = [[UIView alloc] initWithFrame:CGRectMake(250, 230, 70, 1)];
        self.rightHelperLine.backgroundColor = [UIColor whiteColor];
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(85, 230, 150, 2)];
        self.lineView.backgroundColor = [UIColor redColor];
        [self.view addSubview:self.leftHelperLine];
        [self.view addSubview:self.rightHelperLine];
        [self.view addSubview:self.lineView];
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.25;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     CGFloat x=accelerometerData.acceleration.x;
                                                     x = accelerometerData.acceleration.x * kFilteringFactor + x * (1.0 - kFilteringFactor);
                                                     [UIView beginAnimations:@"rotate" context:nil];
                                                     [UIView setAnimationDuration:0.1];
                                                     self.lineView.transform=CGAffineTransformMakeRotation(-x);
                                                     if (x > -0.01 && x < 0.01) {
                                                         DDLogVerbose(@"STABLE: %f", x);
                                                         self.lineView.backgroundColor = [UIColor greenColor];
                                                     } else {
                                                         self.lineView.backgroundColor = [UIColor redColor];
                                                     }
                                                     [UIView commitAnimations];
                                                 }];
    }
}

- (void)switchCameras:(id)sender {
    DDLogVerbose(@"%@: Switching cameras", THIS_FILE);
    [self.captureManager.captureSession stopRunning];
    [self.captureManager switchCameras];
    [self.captureManager.captureSession startRunning]; 
}

- (void)toggleFlash:(id)sender {
    DDLogVerbose(@"%@: Toggling flash", THIS_FILE);
    [self.captureManager toggleFlash];
}

- (void)flashModeToggled:(NSNotification *)notification {
    NSInteger newFlashIndex = [notification.userInfo[@"new"] integerValue];
    DDLogVerbose(@"%@: Previous flash mode: %d  New flash mode: %d",
                 THIS_FILE,
                 [notification.userInfo[@"old"] integerValue],
                 newFlashIndex);
    
    // Change flash button icon!
    switch (newFlashIndex) {
        case 0:
            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
            break;
            
        case 1:
            [self.flashButton setImage:[UIImage imageNamed:@"flash-on"] forState:UIControlStateNormal];
            break;
            
        case 2:
            [self.flashButton setImage:[UIImage imageNamed:@"flash-auto"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
}

- (void)addCloseButton {
    UIImage *closeImage = [UIImage imageNamed:@"cameraclose"];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:
                             CGRectMake(0, 0, closeImage.size.width + 40, 62)];
    DDLogVerbose(@"%@: Image: %@", THIS_FILE, closeImage);
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissCamera) forControlEvents:UIControlEventTouchUpInside];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, -11, 0);
    UIBarButtonItem *closeButtonItemView = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeButtonItemView;
}

- (void)dismissCamera {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shutterButtonPressed {
    //[self.captureManager.captureSession stopRunning];
    [self.captureManager captureStillImage];
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum(self.captureManager.stillImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    DDLogVerbose(@"%@: Original image size: (%f, %f)", THIS_FILE, self.captureManager.stillImage.size.width, self.captureManager.stillImage.size.height);
    
    // Resize image first before saving to album
    CGSize croppedImageSize = kImageSize;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.croppedImage = [UIImage squareImageWithImage:self.captureManager.stillImage scaledToSize:croppedImageSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(self.croppedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            self.captureManager.stillImage = nil;
            
            [self performSegueWithIdentifier:@"showPostingView" sender:self];
            /*UIImageView *view = [[UIImageView alloc] initWithFrame:self.imageCropRect];
            view.image = croppedImage;
            view.layer.borderWidth = 1;
            view.layer.borderColor = [UIColor redColor].CGColor;
            view.contentMode = UIViewContentModeScaleToFill;
            [self.view addSubview:view];*/
        });
    });
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostingView"]) {
        SNFPostingPhotoViewController *postingPhotoVC = (SNFPostingPhotoViewController *)segue.destinationViewController;
        postingPhotoVC.photo = self.croppedImage;
        self.croppedImage = nil;
    }
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
