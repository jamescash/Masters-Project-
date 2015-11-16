//
//  JCGigInvitesVC.m
//  PreAmp
//
//  Created by james cash on 05/10/2015.
//  Copyright © 2015 com.james.www. All rights reserved.
//

#import "JCGigInvitesVC.h"
#import <Parse/Parse.h>
#import "JCParseQuerys.h"
#import "JCInboxDetail.h"
#import "JCEventInviteCell.h"
#import "JCConstants.h"

#import "RESideMenu.h"

#import <QuartzCore/QuartzCore.h>


#import "UIERealTimeBlurView.h"


#import "ILTranslucentView.h"

#import "MGSwipeButton.h"
#import <objc/runtime.h>


@interface JCGigInvitesVC ()
//UI elements
@property (weak, nonatomic) IBOutlet UITableView *MyGigInvitesTable;
@property (weak, nonatomic) IBOutlet UILabel *tableViewHeader;

//Properties
@property (nonatomic,strong) PFObject *selectedInvite;
@property (nonatomic,strong) UIImage *selectedInviteImage;
@property (nonatomic,strong) NSMutableArray *tableViewDataSource;
@property (nonatomic,strong) NSMutableArray *imageFiles;
@property (weak, nonatomic) IBOutlet UIView *navBarDropDown;

//classes
@property (nonatomic,strong) JCParseQuerys *JCParseQuery;
@property (nonatomic,strong) ILTranslucentView *blerView;

@property (nonatomic,strong)JCDropDownMenu *contextMenu;

@end

@implementation JCGigInvitesVC{
    BOOL blerViewOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCustomButtonOnNavBar];
    self.tableViewDataSource = [[NSMutableArray alloc]init];
    self.tableViewHeader.textColor = [UIColor colorWithRed:234.0f/255.0f green:65.0f/255.0f blue:150.0f/255.0f alpha:1.0f];

    self.JCParseQuery = [JCParseQuerys sharedInstance];
    self.imageFiles = [[NSMutableArray alloc]init];
    
    [self.JCParseQuery getMyInvitesforType:JCUserEventUsersTypeUpcoming completionblock:^(NSError *error, NSArray *response) {
        
        if (error) {
            NSLog(@"getMyInvitesforType %@",error);
        }else{

            //self.tableViewDataSource = response;
            //returns an array of user events based on the the type Key;
            //[self.tableViewDataSource removeAllObjects];
            [self.tableViewDataSource addObjectsFromArray:response];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyGigInvitesTable reloadData];
            });
        }
     }];
    
    self.MyGigInvitesTable.emptyDataSetSource = self;
    self.MyGigInvitesTable.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.MyGigInvitesTable.tableFooterView = [UIView new];
}

#pragma - empty Datasource delagte

//- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
//{
//    return [UIImage imageNamed:@"backgroundLogin.png"];
//}

-(CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
    
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

-(NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Past Gigs";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"After you attend gigs they will apper here, this helps you trak all the gigs you and you friends attended in the past.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}



//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
//{
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]};
//    
//    return [[NSAttributedString alloc] initWithString:@"Back" attributes:attributes];
//}


//- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
//{
//    
//    
////    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
////    [activityView startAnimating];
//    
////    return activityView;
//}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableViewDataSource.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    JCEventInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventInviteCell"forIndexPath:indexPath];
    PFObject *eventInvite = [self.tableViewDataSource objectAtIndex:indexPath.row];
    [cell formatCell:eventInvite];
    cell.indexPath = indexPath;
    PFFile *imageFile = [eventInvite objectForKey:@"eventPhoto"];

    cell.BackRoundImage.file = imageFile;
    cell.BackRoundImage.contentMode = UIViewContentModeScaleAspectFill;

    //set up the swipe buttons
cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Mute" icon:[UIImage imageNamed:@""] backgroundColor:[UIColor grayColor]],
                         [MGSwipeButton buttonWithTitle:@"Delete" icon:[UIImage imageNamed:@""] backgroundColor:[UIColor redColor]]];
    
    MGSwipeButton *muteButton = [cell.leftButtons firstObject];
    muteButton.tag = indexPath.row;
    MGSwipeButton *deleteButton = [cell.leftButtons lastObject];
    deleteButton.tag = indexPath.row;
    
    cell.delegate = self;
    cell.leftSwipeSettings.transition = MGSwipeTransitionBorder;
   
    NSUInteger randomNumber = arc4random_uniform(5);
   
    switch (randomNumber) {
                case 0:
                    cell.BackRoundImage.image = [UIImage imageNamed:@"loadingYellow.png"];
                    cell.BackRoundImage.contentMode = UIViewContentModeScaleAspectFill;
    
                    break;
                case 1:
                    cell.BackRoundImage.image = [UIImage imageNamed:@"loadingPink.png"];
                    cell.BackRoundImage.contentMode = UIViewContentModeScaleAspectFill;
    
                    break;
                case 2:
                    cell.BackRoundImage.image = [UIImage imageNamed:@"loadingBlue.png"];
                    cell.BackRoundImage.contentMode = UIViewContentModeScaleAspectFill;
    
                    break;
                case 3:
                    cell.BackRoundImage.image = [UIImage imageNamed:@"loadingGreen.png"];
                    cell.BackRoundImage.contentMode = UIViewContentModeScaleAspectFill;
    
                    break;
                    
            }
    [cell.BackRoundImage loadInBackground];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    self.selectedInvite = [self.tableViewDataSource objectAtIndex:indexPath.row];
    
    JCEventInviteCell *cellatindex = [[JCEventInviteCell alloc]init];
    
    cellatindex = [tableView cellForRowAtIndexPath:indexPath];
    
    self.selectedInviteImage = cellatindex.BackRoundImage.image;
    
    [self performSegueWithIdentifier:@"showEvent" sender:self];
 
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showEvent"]) {
        JCInboxDetail *destinationVC = (JCInboxDetail*) segue.destinationViewController;
        destinationVC.userEvent = self.selectedInvite;
        destinationVC.selectedInviteImage = self.selectedInviteImage;
    }
}
-(void)DownloadImageForeventAtIndex:(NSIndexPath *)indexPath completion:(void (^)( UIImage *,NSError*)) completion {
    
    // if we fetched already, just return it via the completion block
    UIImage *existingImage = self.imageFiles[indexPath.row][@"image"];
    
    if (existingImage){
       completion(existingImage, nil);
    }
    
    PFFile *pfFile = self.imageFiles[indexPath.row][@"pfFile"];
    
    
    [pfFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *eventImage = [UIImage imageWithData:imageData];
            self.imageFiles[indexPath.row][@"image"] = eventImage;
            completion(eventImage, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma - Helper Method

-(BOOL)swipeTableCell:(JCEventInviteCell*)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    
    if (index == 0) {
        NSLog(@"mute button %@",cell);
    }else if (index == 1){
        [self deleteEventFromInboxatIndexPath:cell.indexPath];
    }
    return YES;
}



-(void)deleteEventFromInboxatIndexPath :(NSIndexPath*)indexPath {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"You will be removed from this event and will no longer be able to view it!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = indexPath.row;
    [alert show];
};


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        
        PFObject *eventToDeleteUserFrom = [self.tableViewDataSource objectAtIndex:alertView.tag];
        [self.tableViewDataSource removeObjectAtIndex:alertView.tag];
        
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:alertView.tag inSection:0] ;
       // NSArray *indexs = @[indexpath];
        [self.MyGigInvitesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
        [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:.3];
        
        NSMutableArray *InvitedUsers = [[NSMutableArray alloc]init];
        
        [InvitedUsers addObjectsFromArray:[eventToDeleteUserFrom objectForKey:JCUserEventUsersEventInvited]];
        NSLog(@"%@",InvitedUsers);
        PFUser *currentuser = [PFUser currentUser];
        NSMutableArray *toDelete = [NSMutableArray array];

        for (NSString *userId in InvitedUsers) {
            if ([userId isEqualToString:currentuser.objectId] ) {
                [toDelete addObject:userId];
            }
        }
        [InvitedUsers removeObjectsInArray:toDelete];

        NSLog(@"%@",InvitedUsers);
        [eventToDeleteUserFrom setObject:InvitedUsers forKey:JCUserEventUsersEventInvited];
        [eventToDeleteUserFrom setObject:InvitedUsers forKey:JCUserEventUsersSubscribedForNotifications];
        [eventToDeleteUserFrom saveInBackground];
            
    }

}

-(void)reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.MyGigInvitesTable reloadData];
    });
}

- (void)addCustomButtonOnNavBar
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [menuButton setImage:[UIImage imageNamed:@"iconMenu.png"] forState:UIControlStateNormal];
    //[menuButton setImage:[UIImage imageNamed:@"iconMenu.png"] forState:UIControlStateHighlighted];
    menuButton.adjustsImageWhenDisabled = NO;
    //set the frame of the button to the size of the image (see note below)
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    menuButton.opaque = YES;
    
    [menuButton addTarget:self action:@selector(menuButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    
    
    UITapGestureRecognizer *navbarRightButtonTapped =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(RightnavItemTapped)];
    
    [self.navBarDropDown addGestureRecognizer:navbarRightButtonTapped];
    UIImageView * contextMenuButtonCoverimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCalender.png"]];
    contextMenuButtonCoverimageView.frame = CGRectMake(0, 0, 40, 40);
    [self.navBarDropDown addSubview:contextMenuButtonCoverimageView];
    
    self.navBarDropDown.backgroundColor = [UIColor clearColor];

}
-(void)menuButtonPressed{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)RightnavItemTapped{
    
    if (!self.contextMenu) {
        self.contextMenu = [[JCDropDownMenu alloc]initWithFrame:self.view.bounds];
        [self.navigationController.view addSubview:self.contextMenu];
        self.contextMenu.JCDropDownMenuDelagte = self;
        [self manageBleredLayer];

    }else{
        [self.contextMenu animatContextMenu];
        [self manageBleredLayer];

    }
}

-(void)manageBleredLayer{
    if (blerViewOn) {
        self.blerView.hidden=YES;
        self.navBarDropDown.hidden = NO;

        blerViewOn=NO;
    }else{
        if (!self.blerView) {
            self.blerView = [[ILTranslucentView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:self.blerView];
            self.blerView.translucentAlpha = .9;
            self.blerView.translucentStyle = UIBarStyleDefault;
            self.blerView.translucentTintColor = [UIColor clearColor];
            self.blerView.backgroundColor = [UIColor clearColor];

        }
        self.blerView.hidden=NO;
        self.navBarDropDown.hidden = YES;

        blerViewOn=YES;
    }
}



#pragma - DropDownMenu Delage CallBacks 

-(void)contextMenuButtonCoverClicked{
    [self.contextMenu animatContextMenu];
    [self manageBleredLayer];
}

-(void)contextMenuButtonFirstClicked{
    [self.contextMenu setUserInteractionEnabled:NO];

    [self.JCParseQuery getMyInvitesforType:JCUserEventUsersTypeUpcoming completionblock:^(NSError *error, NSArray *response) {
        
        if (error) {
            NSLog(@"getMyInvitesforType %@",error);
        }else{
            [self.tableViewDataSource removeAllObjects];
            [self.tableViewDataSource addObjectsFromArray:response];
            self.tableViewHeader.text = @"Upcoming Gigs";
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyGigInvitesTable reloadData];
                [self.contextMenu animatContextMenu];
                [self manageBleredLayer];
                [self.contextMenu setUserInteractionEnabled:YES];

            });
        }
    }];}
-(void)contextMenuButtonSecondClicked{
    [self.contextMenu setUserInteractionEnabled:NO];

    [self.JCParseQuery getMyInvitesforType:JCUserEventUsersTypeSent completionblock:^(NSError *error, NSArray *response) {
        
        if (error) {
            NSLog(@"getMyInvitesforType %@",error);
        }else{
            
            [self.tableViewDataSource removeAllObjects];
            [self.tableViewDataSource addObjectsFromArray:response];
            self.tableViewHeader.text = @"Sent";

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyGigInvitesTable reloadData];
                [self.contextMenu animatContextMenu];
                [self manageBleredLayer];
                [self.contextMenu setUserInteractionEnabled:YES];

            });
        }
    }];
}
-(void)contextMenuButtonThirdClicked{
    [self.contextMenu setUserInteractionEnabled:NO];

    [self.JCParseQuery getMyInvitesforType:JCUserEventUsersTypePast completionblock:^(NSError *error, NSArray *response) {
        
        if (error) {
            NSLog(@"getMyInvitesforType %@",error);
        }else{
            
            [self.tableViewDataSource removeAllObjects];
            [self.tableViewDataSource addObjectsFromArray:response];
            self.tableViewHeader.text = @"Past Gigs";

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyGigInvitesTable reloadData];
                [self.contextMenu animatContextMenu];
                [self manageBleredLayer];
                [self.contextMenu setUserInteractionEnabled:YES];

            });
        }
    }];
}





@end
