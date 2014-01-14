//
//  SNFPostingPhotoViewController.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/14/14.
//
//

#import "SNFPostingPhotoViewController.h"

NSInteger const kTextCellType   = 0;
NSInteger const kSwitchCellType = 1;
NSInteger const kScrollViewCellType = 2;

@interface SNFPostingPhotoViewController ()

@property (nonatomic, strong) NSArray *postingCellData;

@end

@implementation SNFPostingPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.navigationController.navigationBar viewWithTag:1] setAlpha:1];
    
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
    
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self.navigationController.navigationBar viewWithTag:1] setAlpha:0.9f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [imageView setImage:self.photo];
        [cell addSubview:imageView];
    }
    
	cell.textLabel.text = [self.postingCellData[indexPath.section][indexPath.row] valueForKey:@"title"];
    
	return cell;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
