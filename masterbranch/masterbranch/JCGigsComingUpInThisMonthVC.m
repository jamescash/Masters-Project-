//
//  JCGigsComingUpInThisMonthVC.m
//  PreAmp
//
//  Created by james cash on 23/10/2015.
//  Copyright © 2015 com.james.www. All rights reserved.
//

#import "JCGigsComingUpInThisMonthVC.h"
#import "JCUpcomingGigTableViewCell.h"
#import "JCParseQuerys.h"
#import "JCSelectFriends.h"
#import "HeaderViewWithImage.h"
#import "HeaderView.h"
#import "MGSwipeButton.h"

@interface JCGigsComingUpInThisMonthVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong) JCParseQuerys *JCParseQuerys;
@property (nonatomic,strong) NSArray *tableviewDataSource;


@end

@implementation JCGigsComingUpInThisMonthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.JCParseQuerys = [JCParseQuerys sharedInstance];
    self.tableview.allowsSelection = NO;
    [self addCustomButtonOnNavBar];
    HeaderViewWithImage *headerView = [HeaderViewWithImage instantiateFromNib];
    PFObject *artist = self.diaryObject.artist;
    
    headerView.HeaderImageView.image = self.diaryObject.artistImage;
    
    headerView.ArtistName.text = [artist objectForKey:@"artistName"];
    
    [self.tableview setParallaxHeaderView:headerView
                                       mode:VGParallaxHeaderModeFill
                                     height:200];

    
    
    [self.JCParseQuerys getUpcomingGigsforAartis:artist onMonthIndex:self.diaryObject.dateComponents.month isIrishQuery:self.IsIrishQuery complectionblock:^(NSError *error, NSArray *response) {
        
        //self.tableViewDataSource = response;
        self.tableviewDataSource = response;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            
        });
        
        
    }];
   
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableview shouldPositionParallaxHeader];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableviewDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JCUpcomingGigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upComingGig"];
    
    [cell formatCellwith:[self.tableviewDataSource objectAtIndex:indexPath.row]];
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Invite Friend" icon:nil backgroundColor:[UIColor colorWithRed:234.0f/255.0f green:65.0f/255.0f blue:150.0f/255.0f alpha:1.0f]]];
    cell.delegate = self;
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    return 85;
    
}


- (void)addCustomButtonOnNavBar
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setImage:[UIImage imageNamed:@"iconBack.png"] forState:UIControlStateNormal];
    backButton.adjustsImageWhenDisabled = NO;
    backButton.frame = CGRectMake(0, 0, 40, 40);
    backButton.opaque = YES;
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customBarItem;
}
-(void)backButtonPressed{
    NSLog(@"back pressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
