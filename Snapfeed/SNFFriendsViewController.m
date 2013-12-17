//
//  SNFFriendsViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import "SNFFriendsViewController.h"
#import "SNFAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SNFFriendsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;

@end

@implementation SNFFriendsViewController

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
    self.title = @"Friends";
    [self getFriendCount];
	// Do any additional setup after loading the view.
}

- (void)getFriendCount {
    /*FBRequestConnection *connection = [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
    }];*/
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *friends = result[@"data"];
        self.friendsLabel.text = [NSString stringWithFormat:@"You have %d friends", [friends count]];
        
        if (error) {
            DDLogError(@"%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(UIButton *)sender {
    
}
@end
