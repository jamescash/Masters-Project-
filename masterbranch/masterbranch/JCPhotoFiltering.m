//
//  JCPhotoFiltering.m
//  masterbranch
//
//  Created by james cash on 21/08/2015.
//  Copyright (c) 2015 com.james.www. All rights reserved.
//

#import "JCPhotoFiltering.h"

@interface JCPhotoFiltering ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) JCPhotoDownLoadRecord *photoRecord;
@end


@implementation JCPhotoFiltering


#pragma mark - Life cycle

- (id)initWithPhotoRecord:(JCPhotoDownLoadRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = theDelegate;
    }
    return self;
}


#pragma mark - Main operation


- (void)main {
    @autoreleasepool {
        
        if (self.isCancelled)
            return;
        
        if (!self.photoRecord.hasImage)
            return;
        
        UIImage *rawImage = self.photoRecord.image;
        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];
        
        if (self.isCancelled)
            return;
        
        if (processedImage) {
            self.photoRecord.image = processedImage;
            self.photoRecord.filtered = YES;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidFinish:) withObject:self waitUntilDone:NO];
        }
    }
    
}

#pragma mark - Filtering image


- (UIImage *)applySepiaFilterToImage:(UIImage *)image {
    
    // This is expensive + time consuming
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled)
        return nil;
    
    //CISepiaTone
    //TODO turn back on filter but change it to suite our needs
    
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
//    CIFilter *filter = [CIFilter filterWithName:@"CIVignette" keysAndValues: kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], nil];
  
    CIFilter *filter = [CIFilter filterWithName:@"nil" keysAndValues: kCIInputImageKey,inputImage,nil];

    
    //CIPhotoEffectNoir
    //CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues: kCIInputImageKey,inputImage,nil];
    
    //TODO need to add second filter
    //CIFilter *secondFilter = [CIFilter filterWithName:@"CIDiscBlur" keysAndValues: kCIInputImageKey, inputImage,@"inputRadius",[NSNumber numberWithFloat:8.0], nil];
    
    CIImage *outputImage = [filter outputImage];
    
    if (self.isCancelled)
        return nil;
    
    // Create a CGImageRef from the context
    // This is an expensive + time consuming
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    }
    
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
}

@end
