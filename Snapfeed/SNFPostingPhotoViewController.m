//
//  SNFPostingPhotoViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/14/14.
//
//

#import "SNFPostingPhotoViewController.h"
#import "SNFFacebook.h"

NSInteger const kTextCellType   = 0;
NSInteger const kSwitchCellType = 1;
NSInteger const kScrollViewCellType = 2;

@interface SNFPostingPhotoViewController ()

@property (nonatomic, strong) NSArray *postingCellData;
@property (nonatomic, strong) CHTTextView *caption;

@end

@implementation SNFPostingPhotoViewController

- (CHTTextView *)caption {
    if (!_caption) {
        _caption = [[CHTTextView alloc] initWithFrame:CGRectMake(100, 10, 220, 80)];
    }
    
    return _caption;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.navigationController.navigationBar viewWithTag:1] setAlpha:1];
    [(UINavigationBar *)[self.navigationController.navigationBar viewWithTag:1] setBarTintColor:[UIColor blackColor]];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
    
    self.postingCellData = @[@[
	                      @{ @"title" : @"",
	                         @"type"    : @2 }
                          ],
	                  @[
	                      @{ @"title" : @"Share Location",
	                         @"type"    : @1 },
	                      @{ @"title" : @"Name This Location",
	                         @"type"    : @0 },
                          ],
                             
	                   @[ @{ @"title" : @"Twitter",
	                         @"type"    : @0 },
                          ]
                      ];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self.navigationController.navigationBar viewWithTag:1] setAlpha:0.9f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return [self.postingCellData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return [self.postingCellData[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    }
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	DDLogVerbose(@"%@: Type: %d for section, row(%d, %d)", THIS_FILE, (int)[[self.postingCellData[indexPath.section][indexPath.row] valueForKey:@"type"] integerValue], (int)indexPath.section, (int)indexPath.row);
	NSInteger cellType = [[self.postingCellData[indexPath.section][indexPath.row] valueForKey:@"type"] integerValue];
	if (cellType == kSwitchCellType) {
		UISwitch *cellSwitch = [[UISwitch alloc] init];
		cellSwitch.tag = [[NSString stringWithFormat:@"%d%d", (int)indexPath.section, (int)indexPath.row] integerValue];
		//[cellSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = cellSwitch;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
		/*NSString *title = [self.postingCellData[indexPath.section][indexPath.row] valueForKey:@"title"];
		BOOL savedSwitch = [[self.userDefaults valueForKey:title] boolValue];
		DDLogVerbose(@"%@: Boolean value for key %@: %d", THIS_FILE, title, savedSwitch);
		cellSwitch.on = savedSwitch;*/
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        [imageView setImage:self.photo];
        [cell addSubview:imageView];
        
        self.caption.font = [UIFont systemFontOfSize:14.0f];
        self.caption.placeholder = @"Write a caption...";
        self.caption.placeholderTextColor = [UIColor flatDarkWhiteColor];
        
        [cell addSubview:self.caption];
    }
    
	cell.textLabel.text = [self.postingCellData[indexPath.section][indexPath.row] valueForKey:@"title"];
    
	return cell;
}

- (IBAction)shareButtonTapped:(UIButton *)sender {
    DDLogVerbose(@"Posting photo!");
    [[SNFFacebook sharedInstance] postPhotoWithInfo:@{@"picture" : UIImagePNGRepresentation(self.photo),
                                                      @"message" : self.caption.text}
                                        andResponse:^(FBRequestConnection *request, id result, NSError *error) {
                                            if (error) {
                                                DDLogError(@"%@: Error posting photo: %@", THIS_FILE, error);
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to post" message:@"Could not post photo to Facebook. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                [alert show];
                                            } else {
                                                DDLogVerbose(@"Response: %@", result);
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
