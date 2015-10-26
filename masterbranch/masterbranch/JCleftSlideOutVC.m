//
//  JCleftSlideOutVC.m
//  masterbranch
//
//  Created by james cash on 17/08/2015.
//  Copyright (c) 2015 com.james.www. All rights reserved.
//

#import "JCleftSlideOutVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"
#import "JCHomeMainScreenVC.h"
#import <Parse/Parse.h>
#import "JCMyFiriendsMyArtistVC.h"
#import "JCParseQuerys.h"






@interface JCleftSlideOutVC ()
//@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (nonatomic,strong) PFUser *currentUser;
//UI elements
@property (weak, nonatomic) IBOutlet UILabel *friends;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (nonatomic,strong) JCParseQuerys *JCParseQuerys;

//MainMenuButtons
- (IBAction)menuButtonHome:(id)sender;
- (IBAction)menuButtonMyInvites:(id)sender;
- (IBAction)menuButtonMusicDiary:(id)sender;
- (IBAction)logout:(id)sender;

@end

@implementation JCleftSlideOutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.JCParseQuerys = [JCParseQuerys sharedInstance];
    self.currentUser = [PFUser currentUser];
    
    
    
    //Make the labes tapabul for number for friends
    //TODO make the number lable work
    self.friends.userInteractionEnabled = YES;
    self.numberOfFriends.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberOfFriendsLableTap)];
    [self.numberOfFriends addGestureRecognizer:tapGesture];
    [self.friends addGestureRecognizer:tapGesture];
    
    
    //Make artist lable tapabul
    self.artist.userInteractionEnabled = YES;
    self.numberOfArtistFollowing.userInteractionEnabled = YES;
    UITapGestureRecognizer *artisttapped =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberOfArtistLableTap)];
    [self.numberOfArtistFollowing addGestureRecognizer:artisttapped];
    [self.artist addGestureRecognizer:artisttapped];
}

-(void)viewWillAppear:(BOOL)animated{
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)UserSelectedLogOut{

    
    [self.JCParseQuerys getMyFriends:^(NSError *error, NSArray *response) {
        [PFObject unpinAllInBackground:response];
    }];
    
    [self.JCParseQuerys getMyAtrits:^(NSError *error, NSArray *response) {
        [PFObject unpinAllInBackground:response];
     }];
    [PFObject unpinAllObjectsInBackgroundWithName:@"MyArtist"];
    [PFObject unpinAllObjectsInBackgroundWithName:@"MyFriends"];
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLoginPage" sender:self];
    
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Home",@"Music Diary", @"Gig Invites", @"Log Out"];
    NSArray *images = @[@"IconHome",@"IconEmpty", @"IconEmpty", @"IconEmpty"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}



- (void)numberOfFriendsLableTap {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *JCMyFiriendsMyArtist = [sb instantiateViewControllerWithIdentifier:@"JCMyFiriendsMyArtistVC"];

    
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:JCMyFiriendsMyArtist] animated:YES];
    
    JCMyFiriendsMyArtistVC *destinationVC = (JCMyFiriendsMyArtistVC*)JCMyFiriendsMyArtist;
    
    destinationVC.tableViewType = @"friends";
    
    [self.sideMenuViewController hideMenuViewController];
    
}

- (void)numberOfArtistLableTap {

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *JCMyFiriendsMyArtist = [sb instantiateViewControllerWithIdentifier:@"JCMyFiriendsMyArtistVC"];
    
    
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:JCMyFiriendsMyArtist] animated:YES];
    
    JCMyFiriendsMyArtistVC *destinationVC = (JCMyFiriendsMyArtistVC*)JCMyFiriendsMyArtist;
    
    destinationVC.tableViewType = @"artist";
    
    [self.sideMenuViewController hideMenuViewController];

}


- (IBAction)menuButtonHome:(id)sender {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenCollectionView"]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)menuButtonMyInvites:(id)sender {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"JCGigInvitesVC"]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)menuButtonMusicDiary:(id)sender {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"JCInbox"]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)logout:(id)sender {
    
    [self UserSelectedLogOut];
}
@end
