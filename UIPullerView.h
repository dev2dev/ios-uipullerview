//
//  UIPullerView.h
//  iOS-UIPullerView
//
//  Created by Kristijan Sedlak on 7/29/11.
//  Copyright 2011 AppStrides. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIPullerViewDefaultMinimalDragSize 65.0f


#pragma mark -

typedef enum
{
	UIPullerStatePulling = 0,
	UIPullerStateNormal = 1,
	UIPullerStateLoading = 2
} 
UIPullerState;

typedef enum
{
	UIPullerDragDirectionFromTop = 0,
	UIPullerDragDirectionFromLeft = 1,
	UIPullerDragDirectionFromBottom = 2,
	UIPullerDragDirectionFromRight = 3,
    UIPullerDragDirectionHorizontal = 4,
    UIPullerDragDirectionVertical = 5
} 
UIPullerDragDirection;


#pragma mark -

@interface UIPullerView : UIView
{
    UIPullerState state;
    NSMutableDictionary *statusMessages;
    UIPullerDragDirection dragDirection;
    CGFloat minimalDragSize;
    BOOL hideStatusLabelWhenLoading;    
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UILabel *statusLabel;
}

@property(nonatomic) UIPullerState state;
@property(nonatomic) UIPullerDragDirection dragDirection;
@property(nonatomic) CGFloat minimalDragSize;
@property(nonatomic) BOOL hideStatusLabelWhenLoading;
@property(nonatomic, readonly, copy) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, readonly, copy) IBOutlet UILabel *statusLabel;

- (void)setStatusMessage:(NSString *)message forState:(UIPullerState)pullerState;
- (NSString *)getStatusMessageForState:(UIPullerState)pullerState;
- (BOOL)scrollViewDidScroll:(UIScrollView *)scrollView;
- (BOOL)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (BOOL)loadingDidFinish;
- (BOOL)isScrollViewOffsetInLoadingArea:(UIScrollView *)scrollView;
- (BOOL)isScrollViewOffsetInDraggableArea:(UIScrollView *)scrollView;

@end
