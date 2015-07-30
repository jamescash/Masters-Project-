//
//  JCSocailStreamController.m
//  masterbranch
//
//  Created by james cash on 28/06/2015.
//  Copyright (c) 2015 com.james.www. All rights reserved.
//

#import "JCSocailStreamController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "JCFeedObject.h"
#import "JCsocialStreamCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface JCSocailStreamController () <UIActionSheetDelegate>
@property (nonatomic, copy) NSMutableArray *prototypeEntitiesFromJSON;
@property (nonatomic, strong) NSMutableArray *feedEntitySections; // 2d array
@property (nonatomic, assign) BOOL cellHeightCacheEnabled;
@property (nonatomic, strong) NSMutableArray *instagramEndpoints;
@property (nonatomic,strong) NSMutableArray *feedDicts;
@end

@implementation JCSocailStreamController{
    
 
    int instagramEndpointsMethodCounter;
}

- (void)viewDidLoad
{
    
    self.JCEndpointdelegate = [[JCEndpointConstructor alloc]init];
    self.JCEndpointdelegate.JCEndpointConstructordelegate = self;
    //[self.JCEndpointdelegate testdelegation];
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.fd_debugLogEnabled = NO;
    self.cellHeightCacheEnabled = YES;
    [self buildEndPointsFroCurrentEvent];
}


-(void)reloadTabeView{
    
    
    
  
                    for (NSString* endpoint in self.JCEndpointdelegate.endpoints) {
    
                        [self connectToInstagramWithCorrectEndPoint:endpoint then:^{
                            //self.feedEntitySections = @[].mutableCopy;
    
    
                             self.feedEntitySections = [[NSMutableArray alloc]init];
                            [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
    
                            [self.tableView reloadData];
    
                        }];
    
    
    
                        
                        
                    };//end of loop
    
};


//This method figures out if the event has happened/happening/happening later and then constructs the appropriat EndPoints and sends them to the connectToInstagramWithCorrectEndPoint method
- (void)buildEndPointsFroCurrentEvent
{

         if ([self.currentevent.status isEqualToString:@"happeningLater"])
    {
       
        

        
        
        [self.JCEndpointdelegate buildHappeningLaterEndPointsForEvent:self.currentevent];
        NSLog(@"searched by Happeninglater (going and getting media by # event.instasearchquery)");

    
   
    }
    
    
    
    
    else if ([self.currentevent.status isEqualToString:@"alreadyHappened"])
    {
       
        self.feedDicts = [[NSMutableArray alloc]init];
        //build all the nessasery endpoints then set off the delegation method
        [self.JCEndpointdelegate buildHappeningLaterEndPointsForEvent:self.currentevent];
        
    
    
    }
    
    
    else{
      
//        NSDictionary *LatLong = [[NSDictionary alloc]init];
//        LatLong = self.currentevent.LatLong;
//        
//        NSString *latitude = LatLong[@"lat"];
//        NSString *Longditude = LatLong [@"long"];
//        
//        InstaEndpoint1 = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search?lat=%@&lng=%@&distance=50&client_id=d767827366a74edca4bece00bcc8a42c",latitude,Longditude];
//        NSLog(@"searched by event currently happening (geo fence endpoint)");
//        
//       
//        [self connectToInstagramWithCorrectEndPoint:InstaEndpoint1 then:^{
//            self.feedEntitySections = @[].mutableCopy;
//            [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
//          
//            [self.tableView reloadData];
//        
//        }];

    }
    
}//end of buildData





#pragma mark - UITableViewDataSource
//The amount of array objects added to the array feedEntitySections determins the amount
//of sections in the tableView doing it this way allows me to dynamically add sections to the tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.feedEntitySections.count;
}
//go down one level in that array to find out how many rows per section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedEntitySections[section] count];

}
//This is where we create the actul cells to place into the tableView at that specific index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //creat a cell from the class JCsocialStreamCell and give the the reuse identifier FDFeedCell
    JCsocialStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FDFeedCell" forIndexPath:indexPath];
    
    //call the configurecell method on that cell
    [self configureCell:cell atIndexPath:indexPath];
    
    //insert that cell
    return cell;
}
//this is where some of the UITableView-FDTemplateLayoutCell magic happens I downloaded the
//UITableView-FDTemplateLayoutCell from gitHub at
//https://github.com/forkingdog/UITableView-FDTemplateLayoutCell
- (void)configureCell:(JCsocialStreamCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    
    //this line of code is where we give the cell is data.
    //This is where we assign the JCFeedObject from the array to the JCsocialStreamCell.
    //This method as all the above methods gets called foe every new cell is created.
    
    cell.entity = self.feedEntitySections[indexPath.section][indexPath.row];
}


#pragma mark - UITableViewDelegate
//this method dynamicly callculates the appropriate hight for each cell
//as it is created and then caches that cells hight so it does not have to be
//calculated if the user scrolls back up to view that cell again. I downLoaded
//the UITableView-FDTemplateLayoutCell form gitHub here
//https://github.com/forkingdog/UITableView-FDTemplateLayoutCell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellHeightCacheEnabled) {
        return [tableView fd_heightForCellWithIdentifier:@"FDFeedCell" cacheByIndexPath:indexPath configuration:^(JCsocialStreamCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:@"FDFeedCell" configuration:^(JCsocialStreamCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}
//ths allows the swipe left to delete the cell option
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutableEntities = self.feedEntitySections[indexPath.section];
        [mutableEntities removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}









//this method connects to instagram and gets back raw JSON data and then it converts the JSON data into JCFeedObjects and
//stores them in an array
-(void)connectToInstagramWithCorrectEndPoint: (NSString*)endpoint then: (void (^)(void))then{
    
    //make a counter so I know when to run the competion handler
    instagramEndpointsMethodCounter = 0;

    NSURL *url = [NSURL URLWithString:endpoint];
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error coming from insta APIcall %@",error);
        } else {
            
            NSDictionary *instaresults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *data = instaresults[@"data"];
            NSLog(@"there was %d items added to the array",[data count]);
                    
                    //fill the mutable array feedDicts with all the instagram Data
                    [self.feedDicts addObjectsFromArray:data];
           
            //increment the counter
            instagramEndpointsMethodCounter ++;
            
            
                    if (instagramEndpointsMethodCounter == [self.JCEndpointdelegate.endpoints count]) {
                 
               
                        NSLog(@"%lu total number is",(unsigned long)[self.feedDicts count]);
                        NSMutableArray *entities = [[NSMutableArray alloc]init];
                    
                        //this is where we take each object from the JSON callback and turn it into a JCFeedObject
                        //and than add it the array prototypeEntitiesFromJSON
                        
                        [self.feedDicts  enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [entities addObject:[[JCFeedObject alloc] initWithDictionary:obj]];
                            }];
                        
                            self.prototypeEntitiesFromJSON = [[NSMutableArray alloc]init];
                        
                            self.prototypeEntitiesFromJSON = entities;
                    
                   
                            dispatch_async(dispatch_get_main_queue(), ^{

                                !then ?: then();
                   
                            });//dispatch main queq
               
                    };// if statment
        }//outer else statment
    }];//end of completion handler
};///end of method




    
    
    
    
    
    
    
    

//#pragma mark - Actions
//
//- (IBAction)refreshControlAction:(UIRefreshControl *)sender
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.feedEntitySections removeAllObjects];
//        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
//        [self.tableView reloadData];
//        [sender endRefreshing];
//    });
//}
//
//- (IBAction)leftSwitchAction:(UISwitch *)sender
//{
//    self.cellHeightCacheEnabled = sender.isOn;
//}
//
//- (IBAction)rightNavigationItemAction:(id)sender
//{
//    [[[UIActionSheet alloc]
//      initWithTitle:@"Actions"
//      delegate:self
//      cancelButtonTitle:@"Cancel"
//      destructiveButtonTitle:nil
//      otherButtonTitles:
//      @"Insert a row",
//      @"Insert a section",
//      @"Delete a section", nil]
//     showInView:self.view];
//}
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    SEL selectors[] = {
//        @selector(insertRow),
//        @selector(insertSection),
//        @selector(deleteSection)
//    };
//    
//    if (buttonIndex < sizeof(selectors) / sizeof(SEL)) {
//        void(*imp)(id, SEL) = (typeof(imp))[self methodForSelector:selectors[buttonIndex]];
//        imp(self, selectors[buttonIndex]);
//    }
//}
//
//- (FDFeedEntity *)randomEntity
//{
//    NSUInteger randomNumber = arc4random_uniform((int32_t)self.prototypeEntitiesFromJSON.count);
//    FDFeedEntity *randomEntity = self.prototypeEntitiesFromJSON[randomNumber];
//    return randomEntity;
//}
//
//- (void)insertRow
//{
//    if (self.feedEntitySections.count == 0) {
//        self.feedEntitySections[0] = @[].mutableCopy;
//    }
//    [self.feedEntitySections[0] insertObject:self.randomEntity atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}
//
//- (void)insertSection
//{
//    [self.feedEntitySections insertObject:@[self.randomEntity].mutableCopy atIndex:0];
//    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//}
//
//- (void)deleteSection
//{
//    if (self.feedEntitySections.count > 0) {
//        [self.feedEntitySections removeObjectAtIndex:0];
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}


//-(void)getInstagramPlaceIDfromFBplaceID: (NSString*) FBplaceIDstring{



//
//    NSString *InstaPlaceIdSearch = [NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?facebook_places_id=%@&client_id=d767827366a74edca4bece00bcc8a42c",FBplaceIDstring];
//
//
//    NSURL *url = [NSURL URLWithString:InstaPlaceIdSearch];
//
//    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//
//        if (error) {
//            NSLog(@"error coming from InstaPlaceIdSearch %@",error);
//        } else {
//
//            NSDictionary *instaresults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//
//
//            NSArray *data = instaresults [@"data"];
//
//            if ([data count]==0) {
//                NSLog(@"couldnt get place ID from instagram");
//            }else{
//            NSDictionary *NSDdata = [data objectAtIndex:0];
//                instaPlaceID = NSDdata[@"id"];
//                //NSLog(@"insta resulte are %@",data);
//                //NSLog(@"%@ instaPlaceID",instaPlaceID);
//
//               InstaEndpoint1 = [NSString stringWithFormat:@"https://api.instagram.com/v1/locations/%@/media/recent?client_id=d767827366a74edca4bece00bcc8a42c",instaPlaceID];
//
//
//
//
//
//                self.instagramEndpoints = [[NSMutableArray alloc]init];
//                [self.instagramEndpoints addObject:InstaEndopint2];
//                [self.instagramEndpoints addObject:InstaEndpoint1];
//
//
//                for (NSString* st in self.instagramEndpoints) {
//
//                    [self connectToInstagramWithCorrectEndPoint:st then:^{
//                        //self.feedEntitySections = @[].mutableCopy;
//
//
//                         self.feedEntitySections = [[NSMutableArray alloc]init];
//                        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
//
//
//                        //NSLog(@"%@ feedEntitySection",self.feedEntitySections);
//                        //NSLog(@"%@ prototypeEntitiesFromJSON",self.prototypeEntitiesFromJSON);
//
//                        //maybe add another section to the feedentitysection!?
//                        [self.tableView reloadData];
//
//                    }];
//
//
//
//
//
//                };//end of loop
//
//
//           }
//
//        }
//    }];
//
//
//
//}




//-(void)getFbPlaceID:(NSString*)venueName location:(NSString*)location{
//
//   // dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//
//
//
//    NSDictionary *parameters = @{@"q":venueName,@"type":@"place",@"center":location,@"distance":@"2000"};
//
//
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                                  initWithGraphPath:@"search"
//                                  parameters:parameters
//                                  HTTPMethod:@"GET"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                          id result,
//                                          NSError *error) {
//
//        NSDictionary *JsonResult = result;
//
//        NSArray *data = JsonResult[@"data"];
//
//        if ([data count]==0) {
//
//            NSLog(@"Couldnt find a place ID on FaceBook for the venue %@",venueName);
//
//        }else{
//
//
//            NSDictionary *object1 = [data objectAtIndex:0];
//
//            FBplaceID = [object1 valueForKey:@"id"];
//
//
//            //NSLog(@"venue name for FB search is %@",venueName);
//
//            //NSLog(@"venue lat long for FB search is %@",location);
//
//            //NSLog(@"%@",data);
//
//            //NSLog(@"%@ FBplace ID",FBplaceID);
//
//            [self getInstagramPlaceIDfromFBplaceID:FBplaceID];
//        }
//
//    }];
//
//
//
//
//
//
//
//
//};

@end