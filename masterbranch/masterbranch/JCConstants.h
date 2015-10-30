//
//  JCConstants.h
//  PreAmp
//
//  Created by james cash on 26/10/2015.
//  Copyright © 2015 com.james.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCConstants : NSObject


#pragma - Parse ClassNames
extern NSString * const JCParseClassUserEvents;
extern NSString * const JCParseClassActivity;


//Backend UserEvents Class - Keys
#pragma - UserEvents  - Keys
extern NSString * const JCUserEventUserGoing;
extern NSString * const JCUserEventUserNotGoing;
extern NSString * const JCUserEventUserMaybeGoing;
extern NSString * const JCUserEventUserGotTickets;
//Backend UserEvents Class - Keys
extern NSString * const JCUserEventUsersInvited;
extern NSString * const JCUserEventUsersEventHostNameUserName;
extern NSString * const JCUserEventUsersTheEventDate;
extern NSString * const JCUserEventUsersEventPhoto;
extern NSString * const JCUserEventUsersEventTitle;
extern NSString * const JCUserEventUsersEventVenue;
extern NSString * const JCUserEventUsersEventHostId;
extern NSString * const JCUserEventUsersEventCity;
extern NSString * const JCUserEventUsersEventInvited;
extern NSString * const JCUserEventUsersSubscribedForNotifications;



//Backend UserEvents Class Local - Keys
extern NSString * const JCUserEventUsersTypeUpcoming;
extern NSString * const JCUserEventUsersTypePast;
extern NSString * const JCUserEventUsersTypeSent;


//Backend Activitys Class - Keys
#pragma - Activitys
extern NSString * const JCUserActivityType;
extern NSString * const JCUActivityTypeUserComment;

extern NSString * const JCUserActivityFromUser;
extern NSString * const JCUserActivityCommentOwner;
extern NSString * const JCUserActivityContent;
extern NSString * const JCUserActivityRelatedObjectId;




#pragma - BandsInTownKeys
extern NSString * const BITJSONDateUnformatted;

#pragma - ParseClasses
extern NSString * const JCParseGeneralKeyCreatedAt;



@end

