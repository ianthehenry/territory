//
//  ViewController.m
//  Territory
//
//  Created by Ian Henry on 4/25/13.
//  Copyright (c) 2013 Ian Henry. All rights reserved.
//

#import "ViewController.h"
#import "HexButton.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger size = 11;

typedef enum {
    PlayerOne = 1,
    PlayerNone = 0,
    PlayerTwo = -1
} Player;

@interface ViewController ()

@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, assign) Player currentPlayer;
@property (nonatomic, retain) UIView *containerView;

@end

@implementation ViewController

- (NSInteger)xForRank:(NSInteger)rank file:(NSInteger)file {
    return rank + file - size + 1;
}

- (NSInteger)yForRank:(NSInteger)rank file:(NSInteger)file {
    return rank - file;
}

- (CGPoint)centerForRank:(NSInteger)rank file:(NSInteger)file {
    return CGPointMake(CGRectGetMidX(self.containerView.bounds) + self.xSpacing * [self xForRank:rank file:file], CGRectGetMidY(self.containerView.bounds) + self.ySpacing * [self yForRank:rank file:file]);
}

- (CGFloat)radius {
    return 30.0f;
}

- (CGFloat)apothem {
    return sqrtf(3.0f) * self.radius / 2.0f;
}

- (CGFloat)xSpacing {
    return 3.0f * self.radius / 2.0f;
}

- (CGFloat)ySpacing {
    return self.apothem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPlayer = PlayerOne;
    self.tiles = [NSMutableArray arrayWithCapacity:size];
    for (NSInteger i = 0; i < size; i++) {
        [self.tiles addObject:[NSMutableArray arrayWithCapacity:size]];
        for (NSInteger j = 0; j < size; j++) {
            self.tiles[i][j] = @(PlayerNone);
        }
    }
    
    CGFloat radius = self.radius;
    CGFloat apothem = self.apothem;
    CGFloat xSpacing = self.xSpacing;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xSpacing * size + radius * 2.0f, apothem * 2.0f * size)];
    containerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    containerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    containerView.backgroundColor = UIColor.clearColor;
    containerView.opaque = NO;
    self.containerView = containerView;
    [containerView release];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    for (NSInteger rank = 0; rank < size; rank++) {
        for (NSInteger file = 0; file < size; file++) {
            NSInteger distance = abs((size - 1) - (rank + file));
            if (distance > size / 2) {
                continue;
            }
            
            CGPoint center = [self centerForRank:rank file:file];
            
            HexButton *button = [[HexButton alloc] initWithFrame:CGRectMake(center.x - radius, center.y - radius, radius * 2.0f, radius * 2.0f)];
            button.tag = size * rank + file;
            [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.containerView addSubview:button];
        }
    }
    
    [self recalculateEverything];
    [self.view addSubview:self.containerView];
}

- (UIColor *)foregroundColorForPlayer:(Player)player {
    switch (player) {
        case PlayerOne:  return UIColor.blackColor;
        case PlayerTwo:  return UIColor.whiteColor;
        case PlayerNone: @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"crazy talk" userInfo:nil];
    }
}

- (UIColor *)backgroundColorForPlayer:(Player)player {
    switch (player) {
        case PlayerOne:  return [UIColor colorWithWhite:0.1f alpha:1.0f];
        case PlayerTwo:  return [UIColor colorWithWhite:0.9f alpha:1.0f];
        case PlayerNone: return [UIColor colorWithWhite:0.5f alpha:1.0f];
    }
}

- (Player)otherPlayer {
    if (self.currentPlayer == PlayerOne) {
        return PlayerTwo;
    } else {
        return PlayerOne;
    }
}

- (void)didTapButton:(HexButton *)button {
    NSLog(@"%i", button.tag);
    
    NSInteger rank = button.tag / size;
    NSInteger file = button.tag % size;
    
    Player stone = [self colorOfStoneAtRank:rank file:file];
    if (stone != PlayerNone) {
        return;
    }
    Player owner = [self ownerOfTileAtRank:rank file:file];
    if (owner == self.otherPlayer) {
        return;
    }
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
    circleView.layer.cornerRadius = 12.5f;
    circleView.layer.borderColor = [self foregroundColorForPlayer:self.otherPlayer].CGColor;
    circleView.layer.borderWidth = 2.0f;
    circleView.backgroundColor = [self foregroundColorForPlayer:self.currentPlayer];
    circleView.center = [self centerForRank:rank file:file];
    self.tiles[rank][file] = @(self.currentPlayer);
    [self.containerView addSubview:circleView];
    [circleView release];
    [self recalculateEverything];
    self.currentPlayer = self.otherPlayer;
}

- (void)recalculateEverything {
    NSMutableDictionary *scores = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, @(PlayerOne), @0, @(PlayerTwo), nil];

    for (NSInteger rank = 0; rank < size; rank++) {
        for (NSInteger file = 0; file < size; file++) {
            NSInteger distance = abs((size - 1) - (rank + file));
            if (distance > size / 2) {
                continue;
            }

            Player owner = [self ownerOfTileAtRank:rank file:file];
            Player stone = [self colorOfStoneAtRank:rank file:file];
            
            if (owner != PlayerNone) {
                if (stone == PlayerNone) {
                    scores[@(owner)] = @([scores[@(owner)] integerValue] + 1);
                } else if (stone != owner) {
                    scores[@(stone)] = @([scores[@(stone)] integerValue] - 1);
                }
            }
            
            HexButton *hexButton = (HexButton *)[self.containerView viewWithTag:rank * size + file];
            [hexButton setHexColor:[self backgroundColorForPlayer:owner]];
        }
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"BLACK: %@ WHITE: %@", scores[@(PlayerOne)], scores[@(PlayerTwo)]];
}

- (Player)colorOfStoneAtRank:(NSInteger)rank file:(NSInteger)file {
    if (rank < 0 || file < 0 || rank >= size || file >= size) {
        return PlayerNone;
    }
    return (Player)[(NSNumber *)self.tiles[rank][file] integerValue];
}

- (BOOL)isCornerRank:(NSInteger)rank file:(NSInteger)file {
    NSInteger distance = abs((size - 1) - (rank + file));
    NSInteger threshold = size / 2;
    if ((rank == 0 && distance == threshold) || (rank == threshold && distance == threshold) || (file == 0 && distance == 0)) {
        return YES;
    }
    if ((file == 0 && distance == threshold) || (rank == size - 1 && distance == threshold) || (file == size - 1 && distance == 0)) {
        return YES;
    }
    return NO;
}

- (Player)ownerOfTileAtRank:(NSInteger)rank file:(NSInteger)file {
    NSInteger playerOneInfluence = 0;
    NSInteger playerTwoInfluence = 0;
    for (NSInteger rankOffset = -1; rankOffset <= 1; rankOffset++) {
        for (NSInteger fileOffset = -1; fileOffset <= 1; fileOffset++) {
            if (rankOffset == fileOffset && rankOffset != 0) {
                continue;
            }
            Player player = [self colorOfStoneAtRank:rank + rankOffset file:file + fileOffset];
            if (player == PlayerOne) {
                playerOneInfluence++;
            } else if (player == PlayerTwo) {
                playerTwoInfluence++;
            }
        }
    }
    if (playerOneInfluence > playerTwoInfluence) {
        return PlayerOne;
    } else if (playerTwoInfluence > playerOneInfluence) {
        return PlayerTwo;
    }
    return PlayerNone;
}

- (void)dealloc {
    [_scoreLabel release];
    [super dealloc];
}
@end
