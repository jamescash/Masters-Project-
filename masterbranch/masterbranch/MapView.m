//
//  MapView.m
//  masterbranch
//
//  Created by james cash on 06/06/2015.
//  Copyright (c) 2015 com.james.www. All rights reserved.
//

#import "MapView.h"


@interface MapView (){
  
    //the bandsintown API call are made on this queue
    dispatch_queue_t APIcalls;
    //the annoations image load is made on this queue
    dispatch_queue_t imageLoad;
    
}


@end

@implementation MapView


-(void)viewWillAppear:(BOOL)animated{
    
    
    
    [self.MkMapViewOutLet setDelegate:self];
    
    
    //creat dispatch queue for bandsintown API call
    if (!APIcalls) {
        APIcalls = dispatch_queue_create("fmapView.BandsintownAPI.1", NULL);
    }
    
    
    
    
    
    eventObject *event = [[eventObject alloc]init];
    
    
    dispatch_async(APIcalls, ^{
        
        
        //call the build master array on the API dispatch queue
        //this method connects to bandsintow api gets all the events data parses it
        //and returs an array of event objects
        [event buildmasterarray:^{
            
            
            self.annotations = [[NSMutableArray alloc]init];
            
            
            [self buildannotations:event.allEvents];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{[self.MkMapViewOutLet addAnnotations:self.annotations];});
            
        }];//end of songkick API call + Data parsing
        
        
        
    });







};


- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}//end of view did load

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}






-(void)buildannotations:(NSArray*)arrayofgigs{
  
    

    
    CLLocationCoordinate2D location;
    
  
    for (eventObject *event in arrayofgigs) {
        
        NSString *latitude = event.LatLong[@"lat"];
        NSString *Long = event.LatLong[@"long"];
        location.latitude = [latitude doubleValue];
        location.longitude = [Long doubleValue];
        Annotation *ann = [[Annotation alloc]init];
        ann.coordinate = location;
        ann.title = event.eventTitle;
        ann.subtitle = event.venueName;
        ann.currentEvent = event;
        ann.status = event.status;
        
          //  dispatch_queue_t me = dispatch_get_current_queue();
          //  NSString *stringRep = [NSString stringWithFormat:@"%s",dispatch_queue_get_label(me)];
          //  NSLog(@"%@",stringRep);

        [self.annotations addObject:ann];
        
        

   }
    
    
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //create the annotation view
    
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    Annotation *currentAnnotaion = [[Annotation alloc]init];
    currentAnnotaion = annotation;
    
    eventObject *event = [[eventObject alloc]init];
    
    event = currentAnnotaion.currentEvent;
    

    
    if ([currentAnnotaion.status isEqualToString: @"alreadyHappened"]) {
        view.pinColor = MKPinAnnotationColorRed;

    }else if ([currentAnnotaion.status isEqualToString:@"happeningLater"]){
        view.pinColor = MKPinAnnotationColorPurple;

    }else if ([currentAnnotaion.status isEqualToString:@"currentlyhappening"]){
        view.pinColor = MKPinAnnotationColorGreen;
    }
    //SEL segue = @selector(segue:);
    //enable annimation
    view.enabled = YES;
    view.animatesDrop = YES;
    view.canShowCallout = YES;
    UIButton *calloutbutton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[calloutbutton addTarget:self
                      //action:@selector(segue:)
                    //  action:@selector(segue:)
      // forControlEvents:UIControlEventTouchUpInside];
    
    //[calloutbutton sendAction:event to:@selector(segue:)forEvent:UIControlEventTouchUpInside];
    
    view.rightCalloutAccessoryView = calloutbutton;
    
    
    //view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    

//        if (!imageLoad) {
//            imageLoad = dispatch_queue_create("com.APIcall.annotationImages", NULL);
//       }
//
//
//    dispatch_async(imageLoad, ^{
//
//        
//        
//        if ([event.mbidNumber isEqualToString:@"empty"]) {
//            
//            UIImageView *aa = [[UIImageView alloc]init];
//            
//            aa = [event getArtistInfoByName:event.InstaSearchQuery];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{view.image = aa.image;});
//            
//            
//        }else{
//            
//            
//            UIImageView *aa = [[UIImageView alloc]init];
//            
//            aa = [event getArtistInfoByMbidNumuber:event.mbidNumber];
//  
//            dispatch_async(dispatch_get_main_queue(), ^{view.image = aa.image;});
//            
//            
//        }
//        
//        //view.leftCalloutAccessoryView = event.coverpic;
//        
//    });


    
    
    
    return view;
};


//here trying to call the get artist cover picture API method when annotation is selected
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
//   
    if (!imageLoad) {
        imageLoad = dispatch_queue_create("com.APIcall.annotationImages", NULL);
    }
    
    eventObject *event = [[eventObject alloc]init];
    Annotation *currentannoation = view.annotation;
    
    event = currentannoation.currentEvent;
  
 dispatch_async(imageLoad, ^{
    
    
    
    if ([event.mbidNumber isEqualToString:@"empty"]) {
        
        event.coverpic = [event getArtistInfoByName:event.InstaSearchQuery];
         //   NSString *stringRep = [NSString stringWithFormat:@"%@",event.coverpic];
        //    NSLog(@"%@",stringRep);
        
       // view.leftCalloutAccessoryView = event.coverpic;
        
        dispatch_async(dispatch_get_main_queue(), ^{view.leftCalloutAccessoryView = event.coverpic;});

        
    }else{
        
        
        //UIImageView *annoationThumb = [[UIImageView alloc]init];

        event.coverpic = [event getArtistInfoByMbidNumuber:event.mbidNumber];
       
      //  NSString *stringRep = [NSString stringWithFormat:@"%@",event.coverpic];
      //  NSLog(@"%@",stringRep);


        dispatch_async(dispatch_get_main_queue(), ^{view.leftCalloutAccessoryView = event.coverpic;});

        
      }
 });

    // [self performSegueWithIdentifier:@"socialStream" sender:self.todaysGigs[indexpath]];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    Annotation *currentannoation = view.annotation;
    //eventObject *event = [[eventObject alloc]init];

    [self performSegueWithIdentifier:@"socialStream" sender:currentannoation.currentEvent];
}



//-(void)segue:(eventObject*)sender {
//    
//    
//    [self performSegueWithIdentifier:@"socialStream" sender:sender];
//
//};



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    
    
    if ([segue.identifier isEqualToString:@"socialStream"])
    {
        
        eventObject *currentevent = sender;
        NSString *stringRep = [NSString stringWithFormat:@"%@",currentevent.eventTitle];
        NSLog(@"%@",stringRep);
        JCSocailStreamController *jc = [segue destinationViewController];
        jc.currentevent = currentevent;

    }
}



@end
