//
//  ViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/18.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
// 随机色
#define XMGColor(r,g,b) [UIColor colorWithRed:(r) / 256.0 green:(g) / 256.0 blue:(b) / 256.0 alpha:1]
#define RandomColor XMGColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#import "ViewController.h"
#import <SceneKit/SceneKit.h>
@interface ViewController ()
@property (nonatomic, strong) SCNView *scnView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSCNView];
    //    [self changeColor];
    [self addButton];
}
-(void)addButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20, 20, 120, 50);
    [button setTitle:@"changeColor" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor  = [UIColor whiteColor];
    [self.view addSubview:button];
}
-(void)changeColor{
    
    SCNNode *bodyNode = [_scnView.scene.rootNode childNodeWithName:@"body" recursively:YES];
    SCNNode *fishNode = [_scnView.scene.rootNode childNodeWithName:@"fish" recursively:YES];
//    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        bodyNode.geometry.firstMaterial.diffuse.contents = RandomColor;
        bodyNode.geometry.firstMaterial.diffuse.contents = RandomColor;
        fishNode.geometry.firstMaterial.diffuse.contents = RandomColor;
//    }];

    
//    //绕y轴一直旋转
//    SCNAction *action = [SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:1]];
//    [bodyNode runAction:action];
//    [fishNode runAction:action];
}
-(void)addSCNView{
    
    //scnview
    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle]URLForResource:@"body" withExtension:@".dae"] options:nil];
    _scnView = [[SCNView alloc]initWithFrame:self.view.bounds];
    _scnView.backgroundColor = [UIColor whiteColor];
    _scnView.allowsCameraControl = YES;
//    _scnView.showsStatistics = YES;

    
    //scene
    SCNScene *scene = [sceneSource sceneWithOptions:nil error:nil];

    _scnView.scene = scene;
    
    //cameranode
    SCNNode *cameranode = [SCNNode node];
    cameranode.camera = [SCNCamera camera];
    cameranode.camera.automaticallyAdjustsZRange = true;
    cameranode.position = SCNVector3Make(0, 0, 100);
    [_scnView.scene.rootNode addChildNode:cameranode];
    
    [self.view addSubview:_scnView];
    
}

@end
