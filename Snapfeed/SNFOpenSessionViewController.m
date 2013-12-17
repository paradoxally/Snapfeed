//
//  SNFOpenSessionViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import "SNFOpenSessionViewController.h"
#import "SNFFacebook.h"

@interface SNFOpenSessionViewController ()

@end

@implementation SNFOpenSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginWithFacebook:(UIButton *)sender {
    // When button is tapped, open Facebook session
    SNFFacebook *facebook = [SNFFacebook sharedInstance];
    [facebook openSession];
}
@end
