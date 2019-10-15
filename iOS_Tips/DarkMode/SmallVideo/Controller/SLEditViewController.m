//
//  SLEditViewController.m
//  DarkMode
//
//  Created by wsl on 2019/10/12.
//  Copyright © 2019 wsl. All rights reserved.
//

#import "SLEditViewController.h"
#import <Photos/Photos.h>
#import "UIView+SLFrame.h"
#import "SLBlurView.h"
#import "SLEditMenuView.h"
#import "SLEditViewController.h"
#import "SLAvPlayer.h"
#import "SLAvCaptureTool.h"
#import "SLDrawView.h"
#import "SLAvEditExport.h"
#import "SLImage.h"
#import "SLImageView.h"

@interface SLEditViewController ()

@property (nonatomic, strong) UIImageView *preview; // 预览视图 展示待编辑的图片或视频

@property (nonatomic, strong) SLBlurView *editBtn; //编辑
@property (nonatomic, strong) SLBlurView *againShotBtn;  // 再拍一次
@property (nonatomic, strong) UIButton *saveAlbumBtn;  //保存到相册

@property (nonatomic, strong) UIButton *cancleEditBtn; //取消编辑
@property (nonatomic, strong) UIButton *doneEditBtn; //完成编辑
@property (nonatomic, strong) SLEditMenuView *editMenuView; //编辑菜单栏
@property (nonatomic, strong) UIButton *trashTips; //垃圾桶提示 拖拽删除 贴图或文字

@property (nonatomic, strong) SLDrawView *drawView; // 涂鸦视图
@property (nonatomic, strong) NSMutableArray <SLImageView *> *stickerArray; // 所有的贴图

@end

@implementation SLEditViewController

#pragma mark - Override
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (BOOL)shouldAutorotate {
    return NO;
}
#pragma mark - UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.preview];
    if (self.image) {
        self.preview.image = self.image;
    }else {
        SLAvPlayer *avPlayer = [SLAvPlayer sharedAVPlayer];
        avPlayer.url = self.videoPath;
        avPlayer.monitor = self.preview;
        [avPlayer play];
    }
    [self.view addSubview:self.againShotBtn];
    [self.view addSubview:self.editBtn];
    [self.view addSubview:self.saveAlbumBtn];
    
    [self.view addSubview:self.cancleEditBtn];
    [self.view addSubview:self.doneEditBtn];
}

#pragma mark - Getter
- (UIImageView *)preview {
    if (_preview == nil) {
        _preview = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _preview.contentMode = UIViewContentModeScaleAspectFit;
        _preview.backgroundColor = [UIColor blackColor];
        _preview.userInteractionEnabled = YES;
    }
    return _preview;
}
- (SLBlurView *)editBtn {
    if (_editBtn == nil) {
        _editBtn = [[SLBlurView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _editBtn.center = CGPointMake(self.view.sl_w/2.0, self.view.sl_h - 80);
        _editBtn.layer.cornerRadius = _editBtn.sl_w/2.0;
        UIButton * btn = [[UIButton alloc] initWithFrame:_editBtn.bounds];
        [btn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(editBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_editBtn addSubview:btn];
    }
    return _editBtn;
}
- (SLBlurView *)againShotBtn {
    if (_againShotBtn == nil) {
        _againShotBtn = [[SLBlurView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _againShotBtn.center = CGPointMake((self.view.sl_w/2 - 70/2.0)/2.0, self.view.sl_h - 80);
        _againShotBtn.layer.cornerRadius = _againShotBtn.sl_w/2.0;
        UIButton * btn = [[UIButton alloc] initWithFrame:_againShotBtn.bounds];
        [btn setImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(againShotBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_againShotBtn addSubview:btn];
    }
    return _againShotBtn;
}
- (UIButton *)saveAlbumBtn {
    if (_saveAlbumBtn == nil) {
        _saveAlbumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _saveAlbumBtn.center = CGPointMake(self.view.sl_w/2.0 + 70/2.0+ (self.view.sl_w/2 - 70/2.0)/2.0, self.view.sl_h - 80);
        _saveAlbumBtn.layer.cornerRadius = _saveAlbumBtn.sl_w/2.0;
        _saveAlbumBtn.backgroundColor = [UIColor whiteColor];
        [_saveAlbumBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [_saveAlbumBtn addTarget:self action:@selector(saveAlbumBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveAlbumBtn;
}
- (UIButton *)cancleEditBtn {
    if (_cancleEditBtn == nil) {
        _cancleEditBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 30, 40, 30)];
        _cancleEditBtn.hidden = YES;
        [_cancleEditBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleEditBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancleEditBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancleEditBtn addTarget:self action:@selector(cancleEditBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleEditBtn;
}
- (UIButton *)doneEditBtn {
    if (_doneEditBtn == nil) {
        _doneEditBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.sl_w - 50 - 15, 30, 40, 30)];
        _doneEditBtn.hidden = YES;
        _doneEditBtn.backgroundColor = [UIColor colorWithRed:45/255.0 green:175/255.0 blue:45/255.0 alpha:1];
        [_doneEditBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneEditBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneEditBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _doneEditBtn.layer.cornerRadius = 4;
        [_doneEditBtn addTarget:self action:@selector(doneEditBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneEditBtn;
}
- (SLEditMenuView *)editMenuView {
    if (!_editMenuView) {
        _editMenuView = [[SLEditMenuView alloc] initWithFrame:CGRectMake(0, self.view.sl_h - 80 -  60, self.view.sl_w, 80 + 60)];
        _editMenuView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _editMenuView.selectEditMenu = ^(SLEditMenuType editMenuType, NSDictionary * _Nullable setting) {
            if (editMenuType == SLEditMenuTypeGraffiti) {
                weakSelf.drawView.userInteractionEnabled = ![setting[@"hidden"] boolValue];
                [weakSelf.preview insertSubview:weakSelf.drawView atIndex:1];
                if (setting[@"lineColor"]) {
                    weakSelf.drawView.lineColor = setting[@"lineColor"];
                }
                if (setting[@"goBack"]) {
                    [weakSelf.drawView goBack];
                }
            }else {
                weakSelf.drawView.userInteractionEnabled = NO;
            }
            if (editMenuType == SLEditMenuTypeSticking) {
                SLImage *image = setting[@"image"];
                if (image) {
                    SLImageView *imageView = [[SLImageView alloc] initWithFrame:CGRectMake(50, 100, image.size.width/[UIScreen mainScreen].scale, image.size.height/[UIScreen mainScreen].scale)];
                    imageView.userInteractionEnabled = YES;
                    imageView.center = CGPointMake(SL_kScreenWidth/2.0, SL_kScreenHeight/2.0);
                    imageView.image = image;
                    [weakSelf.stickerArray addObject:imageView];
                    [weakSelf.preview addSubview:imageView];
                    //拖拽手势
                    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dragPicture:)];
                    pan.minimumNumberOfTouches = 1;
                    [imageView addGestureRecognizer:pan];
                }
            }
        };
        [self.view addSubview:_editMenuView];
    }
    return _editMenuView;
}
- (UIButton *)trashTips {
    if (!_trashTips) {
        _trashTips = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _trashTips.center = CGPointMake(SL_kScreenWidth/2.0, SL_kScreenHeight - 60);
        [_trashTips setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
        [_trashTips setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _trashTips.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _trashTips;
}
- (SLDrawView *)drawView {
    if (!_drawView) {
        _drawView = [[SLDrawView alloc] initWithFrame:CGRectMake(0, 0, SL_kScreenWidth, SL_kScreenHeight)];
        _drawView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        _drawView.drawBegan = ^{
            [weakSelf hiddenEditMenus:YES];
        };
        _drawView.drawEnded = ^{
            [weakSelf hiddenEditMenus:NO];
        };
    }
    return _drawView;
}
- (NSMutableArray *)stickerArray {
    if (!_stickerArray) {
        _stickerArray = [NSMutableArray array];
    }
    return _stickerArray;
}

#pragma mark - EventsHandle
//编辑
- (void)editBtnClicked:(id)sender {
    [self hiddenEditMenus:NO];
    [self hiddenPreviewButton:YES];
}
//再试一次 继续拍摄
- (void)againShotBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
//保存到相册
- (void)saveAlbumBtnClicked:(id)sender {
    if(self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }else if (self.videoPath) {
        //视频录入完成之后在将视频保存到相簿  如果视频过大的话，建议创建一个后台任务去保存到相册
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.videoPath];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            DISPATCH_ON_MAIN_THREAD(^{
                [self againShotBtnClicked:nil];
            });
            if (success) {
                NSLog(@"视频保存至相册 成功");
            } else {
                NSLog(@"保存视频到相册 失败 ");
            }
        }];
    }
}
//保存图片完成后调用的方法
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    DISPATCH_ON_MAIN_THREAD(^{
        [self againShotBtnClicked:nil];
    });
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);
    } else {
        NSLog(@"保存图片成功");
    }
}
//取消编辑
- (void)cancleEditBtnClicked:(id)sender {
    [self hiddenPreviewButton:NO];
    [self hiddenEditMenus:YES];
    
    [self.drawView removeFromSuperview];
    for (UIView *view in self.stickerArray) {
        [view removeFromSuperview];
    }
}
- (void)doneEditBtnClicked:(id)sender {
    [self hiddenPreviewButton:NO];
    [self hiddenEditMenus:YES];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"The love of one's life" ofType:@"mp3"];
    NSURL *bgsoundUrl = [NSURL fileURLWithPath:path];
    SLAvEditExport *videoExportSession = [[SLAvEditExport alloc] initWithAsset:[AVAsset assetWithURL:self.videoPath]];
    NSString *outputVideoFielPath = [NSTemporaryDirectory() stringByAppendingString:@"EditMyVideo.mp4"];
    videoExportSession.outputURL = [NSURL fileURLWithPath:outputVideoFielPath];
    videoExportSession.graffitiView = [self graffitiView];
    videoExportSession.stickerLayers = [self stickerLayers];
    videoExportSession.audioUrls = @[bgsoundUrl];
    videoExportSession.isNativeAudio = YES;
    [videoExportSession exportAsynchronouslyWithCompletionHandler:^(NSError * _Nonnull error) {
        SLAvPlayer *avPlayer = [SLAvPlayer sharedAVPlayer];
        avPlayer.url = videoExportSession.outputURL;
        self.videoPath = videoExportSession.outputURL;
        
        [self.drawView removeFromSuperview];
        for (UIView *view in self.stickerArray) {
            [view removeFromSuperview];
        }
    } progress:^(float progress) {
        
    }];
}
// 拖拽贴图
- (void)dragPicture:(UIPanGestureRecognizer *)pan {
    // 返回的是相对于最原始的手指的偏移量
    CGPoint transP = [pan translationInView:self.preview];
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self hiddenEditMenus:YES];
        [self.view addSubview:self.trashTips];
    } else if (pan.state == UIGestureRecognizerStateChanged ) {
        pan.view.center = CGPointMake(pan.view.center.x + transP.x, pan.view.center.y + transP.y);
        [pan setTranslation:CGPointZero inView:self.preview];
        //是否删除 确定两个rect是否相交
        if (CGRectIntersectsRect(pan.view.frame, self.trashTips.frame)) {
            [_trashTips setTitle:@"松手即可删除" forState:UIControlStateNormal];
            [_trashTips setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else {
            [_trashTips setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
            [_trashTips setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    } else if (pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateEnded) {
        [self hiddenEditMenus:NO];
        //删除拖拽的视图
        if (CGRectIntersectsRect(pan.view.frame, self.trashTips.frame)) {
            [pan.view  removeFromSuperview];
        }
        [self.trashTips removeFromSuperview];
    }
}

#pragma mark - HelpMethods
// 隐藏预览按钮
- (void)hiddenPreviewButton:(BOOL)isHidden {
    self.againShotBtn.hidden = isHidden;
    self.editBtn.hidden = isHidden;
    self.saveAlbumBtn.hidden = isHidden;
}
// 隐藏编辑时菜单按钮
- (void)hiddenEditMenus:(BOOL)isHidden {
    self.cancleEditBtn.hidden = isHidden;
    self.doneEditBtn.hidden = isHidden;
    self.editMenuView.hidden = isHidden;
}
// 涂鸦层
- (UIView *)graffitiView {
    UIView *graffitiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SL_kScreenWidth, SL_kScreenHeight)];
    //涂鸦
    [graffitiView addSubview:self.drawView];
    //    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //    text.text = @"王双龙";
    //    text.backgroundColor = [UIColor blueColor];
    //    [overlayView addSubview:text];
    return graffitiView;
}
// 贴画层
- (NSMutableArray *)stickerLayers {
    NSMutableArray *stickerLayers = [NSMutableArray array];
    for (SLImageView *imageView in self.stickerArray) {
        CALayer *animatedLayer = [CALayer layer] ;
        animatedLayer.frame = imageView.frame;
        if (imageView.imageType == SLImageTypeGIF) {
            CAKeyframeAnimation *gifLayerAnimation = [self animationForGifWithImage:imageView.animatedImage];
            gifLayerAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
            gifLayerAnimation.removedOnCompletion = NO;
            [animatedLayer addAnimation:gifLayerAnimation forKey:@"gif"];
        }else {
            animatedLayer.contentsScale = [UIScreen mainScreen].scale;
            animatedLayer.contents = (__bridge id _Nullable)(imageView.image.CGImage);
        }
        [stickerLayers addObject:animatedLayer];
    }
    return stickerLayers;
}
// Gif 关键帧动画
- (CAKeyframeAnimation *)animationForGifWithImage:(SLImage *)image {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSMutableArray * frames = [NSMutableArray new];
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    CGFloat totalTime = image.totalTime;
    NSInteger frameCount = image.frameCount;
    for (int i = 0; i < frameCount; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / totalTime)]];
        currentTime += [image imageDurationAtIndex:i];
        [frames addObject:(__bridge id)[image imageAtIndex:i].CGImage];
    }
    animation.keyTimes = times;
    animation.values = frames;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    return animation;
}
@end
