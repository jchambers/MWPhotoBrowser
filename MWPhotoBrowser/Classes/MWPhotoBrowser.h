//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

// Delgate
@class MWPhotoBrowser;
@protocol MWPhotoBrowserDelegate <NSObject>
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
@optional
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowserDidFinish:(MWPhotoBrowser *)photoBrowser;
@end

@protocol MWPhotoBrowserActionButtonDelegate
- (UIBarButtonItem *)actionButton;
@end

// MWPhotoBrowser
@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate> 

// Properties
@property (readonly) id<MWPhotoBrowserDelegate> delegate;
@property id<MWPhotoBrowserActionButtonDelegate> actionButtonDelegate;
@property (readonly) NSUInteger currentPageIndex;

// Init
- (id)initWithPhotos:(NSArray *)photosArray  __attribute__((deprecated)); // Deprecated
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setInitialPageIndex:(NSUInteger)index;

// Control visibility
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)hideControlsAfterDelay;
- (void)showProgressHUDWithMessage:(NSString *)message;
- (void)hideProgressHUD:(BOOL)animated;
- (void)showProgressHUDCompleteMessage:(NSString *)message;

@end


