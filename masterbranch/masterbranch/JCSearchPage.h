//
//  JCSearchPage.h
//  masterbranch
//
//  Created by james cash on 15/08/2015.
//  Copyright (c) 2015 com.james.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCSearchPageHTTPClient.h"
#import "UIScrollView+VGParallaxHeader.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "UIScrollView+EmptyDataSet.h"

//@protocol JCSearchPageDelegate;
//@class JCSearchPageDelegate;

@interface JCSearchPage : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate,JCSearchPageHTTPClientdelegate,MGSwipeTableCellDelegate,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>

//@property (nonatomic,weak) id <JCSearchPageDelegate>JCSearchPageDelegate;


@end



//@protocol JCSearchPageDelegate <NSObject>
//-(void)JCSearchPageDidSelectDone:(JCSearchPage*)controller;
//@end


