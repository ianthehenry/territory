//
//  HexButton.m
//  Territory
//
//  Created by Ian Henry on 4/25/13.
//  Copyright (c) 2013 Ian Henry. All rights reserved.
//

#import "HexButton.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat TAU = M_PI * 2.0f;

@interface HexButton ()

@property (nonatomic, retain) CAShapeLayer *hexLayer;

@end

@implementation HexButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (CGFloat)radius {
    return self.bounds.size.width / 2.0f;
}

- (CGFloat)apothem {
    return self.radius * sqrtf(3.0f) / 2.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *path = [[UIBezierPath alloc] init];

    NSMutableArray *points = [NSMutableArray arrayWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        CGFloat angle = TAU * ((CGFloat)i / 6.0f);
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.radius * cosf(angle), self.radius * sinf(angle))]];
    }
    
    [path moveToPoint:[points[0] CGPointValue]];
    for (NSInteger i = 1; i < 6; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }
    [path closePath];
    
    self.hexLayer.path = path.CGPath;
    
    [path release];
    
    self.hexLayer.frame = CGRectMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds), 0, 0);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat xDistance = point.x - CGRectGetMidX(self.bounds);
    CGFloat yDistance = point.y - CGRectGetMidY(self.bounds);
    CGFloat distanceSquared = xDistance * xDistance + yDistance * yDistance;
    return distanceSquared < self.apothem * self.apothem ? self : nil;
}

- (void)setup {
    self.hexLayer = [CAShapeLayer layer];
    self.hexLayer.fillColor = [UIColor colorWithWhite:0.75f alpha:1.0f].CGColor;
    self.hexLayer.lineWidth = 2.0f;
    self.hexLayer.lineJoin = kCALineJoinRound;
    self.hexLayer.strokeColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    self.hexLayer.masksToBounds = NO;
    self.clipsToBounds = NO;
    self.opaque = NO;
    self.backgroundColor = UIColor.clearColor;
    [self.layer addSublayer:self.hexLayer];
}

- (void)setHexColor:(UIColor *)color {
    self.hexLayer.fillColor = color.CGColor;
}

@end
