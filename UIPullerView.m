//
//  UIPullerView.m
//  iOS-UIPullerView
//
//  Created by Kristijan Sedlak on 7/29/11.
//  Copyright 2011 AppStrides. All rights reserved.
//

#import "UIPullerView.h"


#pragma mark -

@implementation UIPullerView

@synthesize state;
@synthesize dragDirection;
@synthesize minimalDragSize;
@synthesize hideStatusLabelWhenLoading;
@synthesize activityIndicatorView;
@synthesize statusLabel;

#pragma mark Setters

- (void)setState:(UIPullerState)iState
{
    switch (iState)
    {
        case UIPullerStatePulling:

            statusLabel.text = [self getStatusMessageForState:UIPullerStatePulling];
            statusLabel.hidden = NO;
            
            break;
        case UIPullerStateLoading:
            
            statusLabel.hidden = hideStatusLabelWhenLoading;
            statusLabel.text = [self getStatusMessageForState:UIPullerStateLoading];
            [activityIndicatorView startAnimating];

            break;
        case UIPullerStateNormal:

            statusLabel.text = [self getStatusMessageForState:UIPullerStateNormal];
            statusLabel.hidden = NO;
            [activityIndicatorView stopAnimating];
            
            break;
    }
    
    state = iState;
}

- (void)setStatusMessage:(NSString *)message forState:(UIPullerState)pullerState
{
    [statusMessages setValue:message forKey:[NSString stringWithFormat:@"%d", pullerState]];
    if (state == pullerState) 
    {
        statusLabel.text = [self getStatusMessageForState:pullerState];
    }
}

#pragma mark Getters

- (NSString *)getStatusMessageForState:(UIPullerState)pullerState
{
    return [statusMessages valueForKey:[NSString stringWithFormat:@"%d", pullerState]];
}

- (CGSize)scrollViewOffsetSize:(UIScrollView *)scrollView
{
    CGSize size = CGSizeMake(0, 0);
    size.width = MAX(scrollView.contentSize.width - scrollView.frame.size.width, 0);
    size.height = MAX(scrollView.contentSize.height - scrollView.frame.size.height, 0);
    return size;
}

- (BOOL)isScrollViewOffsetInLoadingArea:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGSize offsetSize = [self scrollViewOffsetSize:scrollView];
    
    switch (dragDirection) 
    {
        case UIPullerDragDirectionFromTop:
            return offset.y <= -minimalDragSize;
        case UIPullerDragDirectionFromLeft:
            return offset.x <= -minimalDragSize;
        
        case UIPullerDragDirectionFromBottom:
            return offset.y >= offsetSize.height + minimalDragSize;
        case UIPullerDragDirectionFromRight:
            return offset.x >= offsetSize.width + minimalDragSize;
        
        case UIPullerDragDirectionVertical:
            return offset.y <= -minimalDragSize || offset.y >= offsetSize.height + minimalDragSize;
        case UIPullerDragDirectionHorizontal:
            return offset.x <= -minimalDragSize || offset.x >= offsetSize.width + minimalDragSize;
    }
    return NO;
}

- (BOOL)isScrollViewOffsetInDraggableArea:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGSize offsetSize = [self scrollViewOffsetSize:scrollView];
    
    switch (dragDirection) 
    {
        case UIPullerDragDirectionFromTop:
            return offset.y < 0 && offset.y > -minimalDragSize;
        case UIPullerDragDirectionFromLeft:
            return offset.x < 0 && offset.x > -minimalDragSize;
        
        case UIPullerDragDirectionFromBottom:
            return offset.y > 0 && offset.y < offsetSize.height + minimalDragSize;
        case UIPullerDragDirectionFromRight:
            return offset.x > 0 && offset.x < offsetSize.width + minimalDragSize;
        
        case UIPullerDragDirectionVertical:
            return offset.y < 0 && offset.y > -minimalDragSize || offset.y > 0 && offset.y < offsetSize.height + minimalDragSize;
        case UIPullerDragDirectionHorizontal:
            return offset.x < 0 && offset.x > -minimalDragSize || offset.x > 0 && offset.x < offsetSize.width + minimalDragSize;
    }
    return NO;
}

#pragma mark Interface

- (void)buildStatusLabel
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    [self addSubview:label];
    statusLabel = label;
}

- (void)buildActivityIndicatorView
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.contentMode = UIViewContentModeCenter;
    indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    indicator.hidesWhenStopped = YES;
    
    CGSize size = self.frame.size;
    CGRect indicatorFrame = indicator.frame;
    indicatorFrame.origin.x = (size.width-indicatorFrame.size.width) / 2;
    indicatorFrame.origin.y = (size.height-indicatorFrame.size.height) / 2;
    indicator.frame = indicatorFrame;
    
    [self addSubview:indicator];
    activityIndicatorView = indicator;
}

- (void)buildStatusMessages
{
    statusMessages = [[NSMutableDictionary alloc] init];
    [self setStatusMessage:NSLocalizedString(@"Pull to refresh", nil) forState:UIPullerStateNormal];
    [self setStatusMessage:NSLocalizedString(@"Release to refresh", nil) forState:UIPullerStatePulling];
    [self setStatusMessage:NSLocalizedString(@"Loading ...", nil) forState:UIPullerStateLoading];
}

- (void)build
{
    [self buildStatusMessages];
    
    self.state = UIPullerStateNormal;
    self.dragDirection = UIPullerDragDirectionFromTop;
    self.minimalDragSize = UIPullerViewDefaultMinimalDragSize;
}

#pragma mark Scroll View Handlers

- (BOOL)scrollViewDidScroll:(UIScrollView *)scrollView 
{
	if ([scrollView isDragging]) 
    {
		if (state == UIPullerStatePulling && [self isScrollViewOffsetInDraggableArea:scrollView]) 
        {
			self.state = UIPullerStateNormal;
            return YES;
		} 
        else if (state == UIPullerStateNormal && [self isScrollViewOffsetInLoadingArea:scrollView]) 
        {
            self.state = UIPullerStatePulling;
            return YES;
		}
    }
	return NO;
}

- (BOOL)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if ([self isScrollViewOffsetInLoadingArea:scrollView]) 
    {
        self.state = UIPullerStateLoading;
        return YES;
    }
    return NO;
}

- (BOOL)loadingDidFinish
{
    if (state == UIPullerStateLoading) 
    {
        self.state = UIPullerStateNormal;
        return YES;
    }
    return NO;
}

#pragma mark General

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self build];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self buildStatusLabel];
        [self buildActivityIndicatorView];
        [self build];
    }
    return self;
}

#pragma mark General

- (void)dealloc
{
    [statusMessages release];
    [activityIndicatorView release];
    [statusLabel release];
    
    [super dealloc];
}

@end
