//
//  JCMusicDiaryHeader.m
//  PreAmp
//
//  Created by james cash on 11/10/2015.
//  Copyright © 2015 com.james.www. All rights reserved.
//

#import "JCMusicDiaryHeader.h"

@implementation JCMusicDiaryHeader

-(void)setHeaderText:(NSString *)text {
    
    self.month.text = text;
    self.backgroundColor = [UIColor lightGrayColor];
    
    
}

@end