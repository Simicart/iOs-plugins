//
//  SCTheme01SlideShow.m
//
// Copyright 2013 Alexis Creuzot
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "SCTheme01SlideShow.h"
#import <SimiCartBundle/UIImageView+WebCache.h>

#define kSwipeTransitionDuration 0.25

typedef NS_ENUM(NSInteger, SCTheme01SlideShowSlideMode) {
    SCTheme01SlideShowSlideModeForward,
    SCTheme01SlideShowSlideModeBackward,
    SCTheme01SlideShowSlideModeUp,
    SCTheme01SlideShowSlideModeDown
};

@interface SCTheme01SlideShow()
@property (atomic) BOOL doStop;
@property (atomic) BOOL isAnimating;
@property (strong,nonatomic) UIImageView * topImageView;
@property (strong,nonatomic) UIImageView * bottomImageView;

@end

@implementation SCTheme01SlideShow

@synthesize delegate;
@synthesize delay;
@synthesize transitionDuration;
@synthesize transitionType;
//@synthesize images;
@synthesize imagePaths;

- (void)awakeFromNib
{
    [self setDefaultValues];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (void) setDefaultValues
{
    self.clipsToBounds = YES;
    self.imagePaths = [NSMutableArray array];
    _currentIndex = 0;
    delay = 3;
    
    transitionDuration = 1;
    transitionType = SCTheme01SlideShowTransitionFade;
    _doStop = YES;
    _isAnimating = NO;
    
    _topImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _bottomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _topImageView.clipsToBounds = YES;
    _bottomImageView.clipsToBounds = YES;
    [self setImagesContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_bottomImageView];
    [self addSubview:_topImageView];
}

- (void) setImagesContentMode:(UIViewContentMode)mode
{
    _topImageView.contentMode = mode;
    _bottomImageView.contentMode = mode;
}

- (UIViewContentMode) imagesContentMode
{
    return _topImageView.contentMode;
}

- (void) addGesture:(SCTheme01SlideShowGestureType)gestureType
{
    switch (gestureType)
    {
        case SCTheme01SlideShowGestureTap:
            [self addGestureTap];
            break;
        case SCTheme01SlideShowGestureSwipe:
            [self addGestureSwipe];
            break;
        case SCTheme01SlideShowGestureAll:
            [self addGestureTap];
            [self addGestureSwipe];
            break;
        default:
            break;
    }
}

- (void) addImagesFromResources:(NSArray *) names
{
    for(NSString * name in names){
        [self addImage:[UIImage imageNamed:name]];
    }
}

- (void) addImage:(UIImage*) image
{
//    [self.images addObject:image];
//    
//    if([self.images count] == 1){
//        _topImageView.image = image;
//    }else if([self.images count] == 2){
//        _bottomImageView.image = image;
//    }
}

- (void)addImagePath:(NSString *)imagePath{
    [self.imagePaths addObject:imagePath];
    NSURL *url = [NSURL URLWithString:imagePath];
    if([self.imagePaths count] == 1){
        [_topImageView sd_setImageWithURL:url];
    }else if([self.imagePaths count] == 2){
        [_bottomImageView sd_setImageWithURL:url];
    }
}

- (void) emptyAndAddImagesFromResources:(NSArray *)names
{
    [self.imagePaths removeAllObjects];
    _currentIndex = 0;
    [self addImagesFromResources:names];
}

- (void) start
{
//    if([self.images count] <= 1){
//        return;
//    }
    
    if([self.imagePaths count] <= 1){
        return;
    }
    
    _doStop = NO;
    [self performSelector:@selector(next) withObject:nil afterDelay:delay];
}

- (void) next
{
    if(! _isAnimating){
        
        // Next Image
        NSUInteger nextIndex = (_currentIndex+1)%[self.imagePaths count];
//        _topImageView.image = self.images[_currentIndex];
//        _bottomImageView.image = self.images[nextIndex];
        NSString *imagePath = self.imagePaths[_currentIndex];
        [_topImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        imagePath = self.imagePaths[nextIndex];
        [_bottomImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        _currentIndex = nextIndex;
        
        // Animate
        switch (transitionType) {
            case SCTheme01SlideShowTransitionFade:
                [self animateFade];
                break;
                
            case SCTheme01SlideShowTransitionSlide:
                [self animateSlide:SCTheme01SlideShowSlideModeForward];
                break;
            case SCTheme01SlideShowTransitionSlideUpDown:
                [self animateSlide:SCTheme01SlideShowSlideModeDown];
                break;
        }
        
        // Call delegate
        if([delegate respondsToSelector:@selector(SCTheme01SlideShowDidNext:)]){
            [delegate SCTheme01SlideShowDidNext:self];
        }
    }
}


- (void) previous
{
    if(! _isAnimating){
        
        // Previous image
        NSUInteger prevIndex;
        if(_currentIndex == 0){
            prevIndex = [self.imagePaths count] - 1;
        }else{
            prevIndex = (_currentIndex-1)%[self.imagePaths count];
        }
        NSString *imagePath = self.imagePaths[_currentIndex];
        [_topImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        imagePath = self.imagePaths[prevIndex];
        [_bottomImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        _currentIndex = prevIndex;
        
        // Animate
        switch (transitionType) {
            case SCTheme01SlideShowTransitionFade:
                [self animateFade];
                break;
                
            case SCTheme01SlideShowTransitionSlide:
                [self animateSlide:SCTheme01SlideShowSlideModeBackward];
                break;
            case SCTheme01SlideShowTransitionSlideUpDown:
                [self animateSlide:SCTheme01SlideShowSlideModeUp];
                break;
        }
        
        // Call delegate
        if([delegate respondsToSelector:@selector(SCTheme01SlideShowDidPrevious:)]){
            [delegate SCTheme01SlideShowDidPrevious:self];
        }
    }
    
}

- (void) animateFade
{
    _isAnimating = YES;
    
    [UIView animateWithDuration:transitionDuration
                     animations:^{
                         _topImageView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         
                         _topImageView.image = _bottomImageView.image;
                         _topImageView.alpha = 1;
                         
                         _isAnimating = NO;
                         
                         if(! _doStop){
                             [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                             [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                         }
                     }];
}

- (void) animateSlide:(SCTheme01SlideShowSlideMode) mode
{
    _isAnimating = YES;
    
    if(mode == SCTheme01SlideShowSlideModeBackward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(- _bottomImageView.frame.size.width, 0);
    }else if(mode == SCTheme01SlideShowSlideModeForward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(_bottomImageView.frame.size.width, 0);
    }else if (mode == SCTheme01SlideShowSlideModeUp) {
        _bottomImageView.transform = CGAffineTransformMakeTranslation(0, _bottomImageView.frame.size.height);
    }else if (mode == SCTheme01SlideShowSlideModeDown)
    {
        _bottomImageView.transform = CGAffineTransformMakeTranslation(0, -_bottomImageView.frame.size.height);
    }
    
    
    [UIView animateWithDuration:transitionDuration
                     animations:^{
                         
                         if(mode == SCTheme01SlideShowSlideModeBackward){
                             _topImageView.transform = CGAffineTransformMakeTranslation( _topImageView.frame.size.width, 0);
                             _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }else if(mode == SCTheme01SlideShowSlideModeForward){
                             _topImageView.transform = CGAffineTransformMakeTranslation(- _topImageView.frame.size.width, 0);
                             _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }else if (mode == SCTheme01SlideShowSlideModeUp) {
                             _topImageView.transform = CGAffineTransformMakeTranslation(0, -_topImageView.frame.size.height);
                             _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }else if (mode == SCTheme01SlideShowSlideModeDown)
                         {
                             _topImageView.transform = CGAffineTransformMakeTranslation(0, _topImageView.frame.size.height);
                             _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                     }
                     completion:^(BOOL finished){
                         
                         _topImageView.image = _bottomImageView.image;
                         _topImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                         _isAnimating = NO;
                         
                         if(! _doStop){
                             [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                             [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                         }
                     }];
}


- (void) stop
{
    _doStop = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
}

#pragma mark - Gesture Recognizers initializers
- (void) addGestureTap
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          
                                                          initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void) addGestureSwipe
{
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [self addGestureRecognizer:swipeRightGestureRecognizer];
}

#pragma mark - Gesture Recognizers handling
- (void)handleSingleTap:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    CGPoint pointTouched = [gesture locationInView:self.topImageView];
    
    if (pointTouched.x <= self.topImageView.center.x)
    {
        [self previous];
    }
    else
    {
        [self next];
    }
}

- (void) handleSwipe:(id)sender
{
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    
    float oldTransitionDuration = self.transitionDuration;
    
    self.transitionDuration = kSwipeTransitionDuration;
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self next];
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self previous];
    }
    
    self.transitionDuration = oldTransitionDuration;
}

@end

