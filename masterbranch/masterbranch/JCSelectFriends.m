//
//  JCSelectFriends.m
//  PreAmp
//
//  Created by james cash on 19/09/2015.
//  Copyright © 2015 com.james.www. All rights reserved.
//

#import "JCSelectFriends.h"
#import "JCParseQuerys.h"
#import "UIImage+Resize.h"
#import "JCParseQuerys.h"
#import "JCMyFriendsCell.h"
#import <ParseUI/ParseUI.h>
#import "ILTranslucentView.h"
#import "JCConstants.h"
#import <Google/Analytics.h>
#import "GAI.h"

@interface JCSelectFriends ()

@property (nonatomic,strong) NSMutableArray *MyFriends;
@property (nonatomic,strong) PFRelation *FriendRelations;
@property (nonatomic,strong) NSMutableArray *recipents;

//classes
@property (nonatomic,strong) JCParseQuerys *JCParseQuery;

@property (nonatomic,strong) ILTranslucentView *blerView;
@property (nonatomic,weak) UILabel *Lablesending;
@property (weak, nonatomic) IBOutlet UILabel *lablePageTitle;

////actions
//- (IBAction)CancleButton:(id)sender;
//- (IBAction)Send:(id)sender;



@end

@implementation JCSelectFriends{
    BOOL sendingLong;
    BOOL sent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MyFriends = [[NSMutableArray alloc]init];
    sendingLong = YES;
    sent = NO;
    [self addCustomButtonOnNavBar];
    [self.tableView setContentInset:UIEdgeInsetsMake(-50,0,0,0)];
    self.recipents = [[NSMutableArray alloc]init];

    self.lablePageTitle.text = @"Choose friends";
    [self.lablePageTitle setFont:[UIFont fontWithName:@"Helvetica-light" size:25]];
    self.lablePageTitle.textColor = [UIColor colorWithRed:234.0f/255.0f green:65.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    _JCParseQuery = [JCParseQuerys sharedInstance];

    [self.JCParseQuery getMyFriends:^(NSError *error, NSArray *response) {
        
        
        
        if ([self.tableViewType isEqualToString:JCSendEventIntivesPageAddUserToExistingEvent ]) {
            
            
            //if were just adding friends to an event make sure we take out all the friends that were already invited.
            NSArray *friendsAlreadyInvited = [self.ParseEventObject objectForKey:JCUserEventUsersEventInvited];
            NSMutableArray *FriendsNotYetInvtied = [[NSMutableArray alloc]init];
            [FriendsNotYetInvtied addObjectsFromArray:response];
            
            for (PFUser *friend in response) {
               
                if ([friendsAlreadyInvited containsObject:friend.objectId]) {
                    [FriendsNotYetInvtied removeObject:friend];
                }
            }
            
            [self.MyFriends addObjectsFromArray:FriendsNotYetInvtied];
        
        
        }else{
            //this is creating an event o we can show all friends
            //SELF.Myfirends = table view data source
            [self.MyFriends addObjectsFromArray:response];
         }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.MyFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JCMyFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    PFUser *user = [self.MyFriends objectAtIndex:indexPath.row];
    [cell formateCell:user];
    
    //NSLog(@"%@",user);
    
    PFFile *profilePic = [user objectForKey:@"thumbnailProfilePicture"];
    cell.userImage.file = profilePic;
    [cell.userImage loadInBackground];

        if ([self.recipents containsObject:user.objectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFUser *user = [self.MyFriends objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
  
    //add and remove recipients as the user selects names
    if (cell.accessoryType == UITableViewCellAccessoryNone ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipents addObject:user.objectId];
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipents removeObject:user.objectId];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}



- (void)CancleButton{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.recipents removeAllObjects];
}

- (void)Send{
    
    
    //Track Button clicks
 
    
    if ([self.tableViewType isEqualToString:JCSendEventIntivesPageAddUserToExistingEvent]) {
        
        [self addBlerView];

        [self.JCParseQuery addUsersToExistingParseUserEvent:self.ParseEventObject UsersToadd:self.recipents completionBlock:^(NSError *error) {
            
            if (error) {
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    sent = YES;
                   
                 
                    CGRect frame = self.Lablesending.frame;
                    frame.origin.x += 40.0f;
                    self.Lablesending.frame = frame;
                    self.Lablesending.text = @"Done!";
                    self.Lablesending.textAlignment = NSTextAlignmentNatural;
                    [self performSelector:@selector(dismissViewController)
                               withObject:self
                               afterDelay:1];
                    
                    [self.recipents removeAllObjects];
                    NSLog(@"event created");
                    
                });
            }
            
        }];
        
        
    }else{
    
    
    if ([self.recipents count]==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Try again!" message:@"Ooops please select some friends" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
        [alert show];
    }else{
    
        
    //defensive code
    if (self.currentEvent == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Try again!" message:@"Ooops something went wrong" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"       // Event category (required)
                                                              action:@"button_press"    // Event action (required)
                                                               label:@"CreatEvent_SelectUserScreen" // Event label
                                                               value:nil] build]];      // Event value
        //Seems like we have an event object lets upload it then dismiss the VC
       
        [self addBlerView];
        PFUser *currentUser = [PFUser currentUser];
        [self.recipents addObject:currentUser.objectId];
        [self.JCParseQuery creatUserEvent:self.currentEvent invitedUsers:self.recipents complectionBlock:^(NSError *error) {
            
            if (error) {
                //show alert view
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"oops!" message:@"Please try sending creating that event again" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
                [self.recipents removeAllObjects];
                [alert show];

                sent = YES;
                CGRect frame = self.Lablesending.frame;
                frame.origin.x += 40.0f;
                self.Lablesending.frame = frame;
                self.Lablesending.text = @"Failed!";
                self.Lablesending.textAlignment = NSTextAlignmentNatural;
                [self performSelector:@selector(dismissViewController)
                           withObject:self
                           afterDelay:1];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    sent = YES;
                    CGRect frame = self.Lablesending.frame;
                    frame.origin.x += 40.0f;
                    self.Lablesending.frame = frame;
                    self.Lablesending.text = @"Done!";
                    self.Lablesending.textAlignment = NSTextAlignmentNatural;
                    [self performSelector:@selector(dismissViewController)
                               withObject:self
                               afterDelay:1];
                    
                    [self.recipents removeAllObjects];
                    NSLog(@"event created");
                
            });
               
            }
            
            
        }];
        
        
       }
     }
   }
}
    

-(void)addBlerView{
    
    self.blerView = [[ILTranslucentView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.blerView];
    self.Lablesending = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, 200, 40)];
    
    self.Lablesending.text = @"Creating event...";
    self.Lablesending.clipsToBounds = YES;
    self.Lablesending.textAlignment = NSTextAlignmentLeft;
    [self.Lablesending setBackgroundColor:[UIColor clearColor]];
    [self.Lablesending setFont:[UIFont fontWithName:@"Helvetica-light" size:25]];
    self.Lablesending.textColor = [UIColor colorWithRed:234.0f/255.0f green:65.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    self.Lablesending.center = self.blerView.center;
    CGRect frame = self.Lablesending.frame;
    frame.origin.x += 20.0f;
    frame.origin.y += -40.0f;
    self.Lablesending.frame = frame;
    
    [self.blerView addSubview:self.Lablesending];
    
    self.blerView.translucentAlpha = .9;
    self.blerView.translucentStyle = UIBarStyleDefault;
    self.blerView.translucentTintColor = [UIColor clearColor];
    self.blerView.backgroundColor = [UIColor clearColor];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval: .5f target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)addCustomButtonOnNavBar
{
    
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [cancleButton setImage:[UIImage imageNamed:@"iconCancle.png"] forState:UIControlStateNormal];
    cancleButton.adjustsImageWhenDisabled = NO;
    cancleButton.frame = CGRectMake(0, 0, 40, 40);
    cancleButton.opaque = YES;
    
    [cancleButton addTarget:self action:@selector(CancleButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:cancleButton];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setImage:[UIImage imageNamed:@"iconSent.png"] forState:UIControlStateNormal];
    sendButton.adjustsImageWhenDisabled = NO;
    sendButton.frame = CGRectMake(0, 0, 40, 40);
    
    [sendButton addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendbarbutton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.navigationItem.rightBarButtonItem = sendbarbutton;
    self.navigationItem.hidesBackButton = YES;
    
    
}
-(void)updateLabel{
    
    if (!sent) {
        if (sendingLong) {
            self.Lablesending.text = @"Creating event..";
            sendingLong = NO;
            
        }else{
            self.Lablesending.text = @"Creating event...";
            sendingLong = YES;
            
        }
    }
    
};

-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];

};

@end
