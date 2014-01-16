//
//  CaptureSessionManager.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/3/14.
//
//

#import "CaptureSessionManager.h"
#import "SNFTakePhotoViewController.h"
#import <ImageIO/ImageIO.h>

@interface CaptureSessionManager ()

@property (nonatomic) BOOL isUsingFrontFacingCamera;

@end

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
		[captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)addVideoInputFrontCamera:(BOOL)front {
	NSArray *devices = [AVCaptureDevice devices];
	AVCaptureDevice *frontCamera;
	AVCaptureDevice *backCamera;
    
	for (AVCaptureDevice *device in devices) {
		DDLogVerbose(@"Device name: %@", [device localizedName]);
        
		if ([device hasMediaType:AVMediaTypeVideo]) {
			if ([device position] == AVCaptureDevicePositionBack) {
				DDLogVerbose(@"Device position : back");
				backCamera = device;
			}
			else {
				DDLogVerbose(@"Device position : front");
				frontCamera = device;
			}
		}
	}
    
	NSError *error = nil;
    
	if (front) {
		AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
				[[self captureSession] addInput:frontFacingCameraDeviceInput];
				self.isUsingFrontFacingCamera = YES;
			}
			else {
				DDLogVerbose(@"Couldn't add front facing video input");
				self.isUsingFrontFacingCamera = NO;
			}
		}
	}
	else {
		AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
				[[self captureSession] addInput:backFacingCameraDeviceInput];
				self.isUsingFrontFacingCamera = NO;
			}
			else {
				DDLogVerbose(@"Couldn't add back facing video input");
			}
		}
	}
}

- (void)addStillImageOutput {
	[self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[[self stillImageOutput] setOutputSettings:outputSettings];
    
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in[[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in[connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}
    
	[[self captureSession] addOutput:[self stillImageOutput]];
}

// use front/back camera
- (void)switchCameras {
	AVCaptureDevicePosition desiredPosition;
	if (self.isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
    
	for (AVCaptureDevice *d in[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in[[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
	self.isUsingFrontFacingCamera = !self.isUsingFrontFacingCamera;
}

- (void)toggleFlash {
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ([device hasFlash]) {
		[device lockForConfiguration:nil];
        
		AVCaptureFlashMode previousFlashMode = device.flashMode;
        
		// Toggling the 3 states of the flash
		if (device.flashMode == AVCaptureFlashModeAuto) {
			[device setFlashMode:AVCaptureFlashModeOff];
		}
		else if (device.flashMode == AVCaptureFlashModeOff) {
			[device setFlashMode:AVCaptureFlashModeOn];
		}
		else if (device.flashMode == AVCaptureFlashModeOn) {
			[device setFlashMode:AVCaptureFlashModeAuto];
		}
        
		AVCaptureFlashMode currentFlashMode = device.flashMode;
        
		[[NSNotificationCenter defaultCenter] postNotificationName:flashModeChangedNotificationName
		                                                    object:self
		                                                  userInfo:@{ @"old" : [NSNumber numberWithInt:previousFlashMode],
		                                                              @"new" : [NSNumber numberWithInt:currentFlashMode] }];
        
		[device unlockForConfiguration];
	}
}

- (void)captureStillImage {
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in[[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in[connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}
    
	UIDeviceOrientation deviceOrientation =
    [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation;
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		avcaptureOrientation  = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		avcaptureOrientation  = AVCaptureVideoOrientationLandscapeLeft;
	else if (deviceOrientation == UIDeviceOrientationPortrait)
		avcaptureOrientation = AVCaptureVideoOrientationPortrait;
    
	[videoConnection setVideoOrientation:avcaptureOrientation];
	DDLogVerbose(@"About to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
	                                                     completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             if (error) {
                                                                 DDLogError(@"%@: %@", THIS_FILE, error);
                                                                 return;
                                                             }
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
                                                                 DDLogVerbose(@"Attachments: %@", exifAttachments);
                                                             }
                                                             else {
                                                                 DDLogVerbose(@"No attachments");
                                                             }
                                                             if (imageSampleBuffer) {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 [self setStillImage:image];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                             }
                                                             else {
                                                                 DDLogError(@"%@: Buffer is NULL", THIS_FILE);
                                                             }
                                                         }];
}

- (void)dealloc {
	[[self captureSession] stopRunning];
}

@end
