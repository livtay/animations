//
//  ViewController.m
//  Animations
//
//  Created by Olivia Taylor on 10/7/16.
//  Copyright © 2016 Olivia Taylor. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *ball;
@property (nonatomic) BOOL isBallRolling;
@property (nonatomic, strong) UIView *paddle;
@property (nonatomic) CGPoint paddleCenterPoint;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic) UIView *bottom;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UIButton *restartButton;
@property (nonatomic, strong) UILabel *loseLabel;

- (IBAction)startButtonTapped:(id)sender;
- (void)playWithBall;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startScreen {
    [self.paddle removeFromSuperview];
    [self.ball removeFromSuperview];
    [self.loseLabel removeFromSuperview];
    [self.restartButton removeFromSuperview];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton addTarget:self action:@selector(startButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setTitle:@"PLAY!" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor greenColor];
    self.startButton.frame = CGRectMake(screenWidth/2 - 75.0, screenHeight/2 - 40.0, 160.0, 40.0);
    [self.view addSubview:self.startButton];
    
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(100.0, 10.0, 40.0, 40.0)];
    self.ball.backgroundColor = [UIColor redColor];
    self.ball.layer.cornerRadius = 20.0;
    self.ball.layer.borderColor = [UIColor blackColor].CGColor;
    self.ball.layer.borderWidth = 0.0;
    [self.view addSubview:self.ball];
    
    self.paddle = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2, screenHeight - 75.0, 100, 30.0)];
    self.paddle.backgroundColor = [UIColor blueColor];
    self.paddle.layer.cornerRadius = 15.0;
    self.paddleCenterPoint = self.paddle.center;
    [self.view addSubview:self.paddle];
    
    self.bottom = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 5.0, screenWidth, 5.0)];
    self.bottom.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.bottom];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)startButtonTapped:(id)sender {
    
    [self playWithBall];
    self.startButton.hidden = YES;
}

- (void)playWithBall {
    
    self.pusher = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
    self.pusher.pushDirection = CGVectorMake(0.5, 1.0);
    self.pusher.active = YES;
    [self.animator addBehavior:self.pusher];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.paddle, self.bottom]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [collisionBehavior addBoundaryWithIdentifier:@"bottom"
                                       fromPoint:CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y)
                                         toPoint:CGPointMake(self.view.frame.origin.x + self.view.frame.size.width, self.view.frame.origin.y)];
    
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.collisionDelegate = self;
    [self.animator addBehavior:collisionBehavior];
    
    UIDynamicItemBehavior *ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    ballBehavior.elasticity = 1.0;
    ballBehavior.resistance = 0.0;
    ballBehavior.friction = 0.0;
    ballBehavior.allowsRotation = NO;
    [self.animator addBehavior:ballBehavior];
    
    UIDynamicItemBehavior *paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle]];
    paddleBehavior.allowsRotation = NO;
    paddleBehavior.density = 100000.0;
    [self.animator addBehavior:paddleBehavior];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    CGFloat yPoint = self.paddleCenterPoint.y;
    CGPoint paddleCenter = CGPointMake(touchLocation.x, yPoint);
    
    self.paddle.center = paddleCenter;
    [self.animator updateItemUsingCurrentState:self.paddle];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id)item1 withItem:(id)item2 atPoint:(CGPoint)p {
    
    if (item1 == self.ball && item2 == self.paddle) {
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.angle = 0.0;
        pushBehavior.magnitude = 1.0;
        [self.animator addBehavior:pushBehavior];
    } else {
        [self.animator removeAllBehaviors];
        [self youLose];
    }
}

- (void)youLose {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.loseLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2 - 75.0, screenHeight/2 - 25.0, 150.0, 50.0)];
    self.loseLabel.backgroundColor = [UIColor orangeColor];
    self.loseLabel.text = @"GAME OVER";
    self.loseLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.loseLabel];
    
    self.restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.restartButton addTarget:self action:@selector(startScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.restartButton setTitle:@"Play Again!" forState:UIControlStateNormal];
    self.restartButton.backgroundColor = [UIColor orangeColor];
    self.restartButton.frame = CGRectMake(screenWidth/2 - 75.0, screenHeight/2 + 45.0, 150.0, 40.0);
    [self.view addSubview:self.restartButton];
    
} 


@end





















































