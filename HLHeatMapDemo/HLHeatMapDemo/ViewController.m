//
//  ViewController.m
//  HLHeatMapDemo
//
//  Created by huaxingyunrui on 2019/7/26.
//  Copyright © 2019 hanlin. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+HLHeatMap.h"
@interface ViewController ()
/**球场*/
@property (nonatomic,strong) UIImageView * stadium;
/**热图*/
@property (nonatomic,strong) UIImageView * heatMap;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatUI];
}
- (void)creatUI{
    self.stadium = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HLMatchReportStadiumOne"]];
    [self.view addSubview:self.stadium];
    self.stadium.contentMode = UIViewContentModeScaleAspectFit;
    self.stadium.frame = CGRectMake(0, 100, 300, 200);
    
    
    self.heatMap = [[UIImageView alloc]init];
    [self.stadium addSubview:self.heatMap];
    self.heatMap.contentMode = UIViewContentModeScaleAspectFit;
    self.heatMap.frame = CGRectMake(0, 100, 300, 200);
    
    
    
    NSMutableArray * points = [NSMutableArray array];
    NSMutableArray * weights = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 300; i ++) {
        float X = [self getRandomNumber:20 to:(300)];
        float Y = [self getRandomNumber:20 to:(200)];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(X, Y)]];
        [weights addObject:[NSNumber numberWithInteger:[self getRandomNumber:0 to:5]]];
    }
    self.heatMap.image = [UIImage heatMapWithRect:self.stadium.bounds boost:0.5 points:points weights:weights weightsAdjustmentEnabled:NO groupingEnabled:NO];
    
    
}

/**
 获取指定范围的随机数
 
 @param from 起始点
 @param to 结束点
 @return 获取到的随机数
 */
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}
@end
