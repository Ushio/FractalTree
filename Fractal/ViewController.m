//
//  ViewController.m
//  Fractal
//
//  Created by 吉村 篤 on 2013/03/17.
//  Copyright (c) 2013年 吉村 篤. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKMath.h>

@implementation ViewController
{
    IBOutlet UIImageView *canvas;
    int iterationCount;
    
    NSTimer *timer;
    NSDate *startime;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    canvas.layer.borderWidth = 1.0;
    canvas.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//basic
- (void)drawTree:(CGContextRef)context iteration:(int)iteration beg:(GLKVector2)beg end:(GLKVector2)end
{
    CGPoint line[] = {{beg.x, beg.y}, {end.x, end.y}};
    CGContextStrokeLineSegments(context, line, 2);
    
    if(iteration <= 0)
    {
//        //NOP
//        float radius = 2.0;
//        CGContextFillEllipseInRect(context, CGRectMake(end.x - radius, end.y - radius, radius * 2.0f, radius * 2.0f));
    }
    else
    {
        GLKVector2 vector = GLKVector2Subtract(end, beg);
        GLKVector2 nvector = GLKVector2Normalize(vector);
        
        GLKMatrix3 rotateL = GLKMatrix3MakeRotation(GLKMathDegreesToRadians( 30.0f), 0, 0, 1);
        GLKMatrix3 rotateR = GLKMatrix3MakeRotation(GLKMathDegreesToRadians(-30.0f), 0, 0, 1);
        GLKVector3 rotatedL3 = GLKMatrix3MultiplyVector3(rotateL, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector3 rotatedR3 = GLKMatrix3MultiplyVector3(rotateR, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector2 rotatedL = {rotatedL3.x, rotatedL3.y};
        GLKVector2 rotatedR = {rotatedR3.x, rotatedR3.y};
        
        float centerLength = GLKVector2Distance(end, beg) * 0.9;
        float sideLength = GLKVector2Distance(end, beg) * 0.5;
        GLKVector2 leftEnd   = GLKVector2Add(end, GLKVector2MultiplyScalar(rotatedL, sideLength));
        GLKVector2 centerEnd = GLKVector2Add(end, GLKVector2MultiplyScalar(nvector, centerLength));
        GLKVector2 rightEnd  = GLKVector2Add(end, GLKVector2MultiplyScalar(rotatedR, sideLength));
        
        [self drawTree:context iteration:iteration - 1 beg:end end:leftEnd];
        [self drawTree:context iteration:iteration - 1 beg:end end:centerEnd];
        [self drawTree:context iteration:iteration - 1 beg:end end:rightEnd];
    }
}

- (void)drawTree:(CGContextRef)context iteration:(int)iteration beg:(GLKVector2)beg end:(GLKVector2)end move:(float)move
{
    CGPoint line[] = {{beg.x, beg.y}, {end.x, end.y}};
    CGContextStrokeLineSegments(context, line, 2);
    
    if(iteration <= 0)
    {
        //        //NOP
        //        float radius = 2.0;
        //        CGContextFillEllipseInRect(context, CGRectMake(end.x - radius, end.y - radius, radius * 2.0f, radius * 2.0f));
    }
    else
    {
        GLKVector2 vector = GLKVector2Subtract(end, beg);
        GLKVector2 nvector = GLKVector2Normalize(vector);
        
        GLKMatrix3 rotateL = GLKMatrix3MakeRotation(GLKMathDegreesToRadians( 30.0f), 0, 0, 1);
        GLKMatrix3 rotateR = GLKMatrix3MakeRotation(GLKMathDegreesToRadians(-30.0f), 0, 0, 1);
        GLKVector3 rotatedL3 = GLKMatrix3MultiplyVector3(rotateL, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector3 rotatedR3 = GLKMatrix3MultiplyVector3(rotateR, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector2 rotatedL = {rotatedL3.x, rotatedL3.y};
        GLKVector2 rotatedR = {rotatedR3.x, rotatedR3.y};
        
        GLKMatrix3 moveMatrix = GLKMatrix3MakeRotation(GLKMathDegreesToRadians(move), 0, 0, 1);
        GLKVector3 movedL3 = GLKMatrix3MultiplyVector3(moveMatrix, GLKVector3Make(rotatedL.x, rotatedL.y, 0.0f));
        GLKVector3 movedC3 = GLKMatrix3MultiplyVector3(moveMatrix, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector3 movedR3 = GLKMatrix3MultiplyVector3(moveMatrix, GLKVector3Make(rotatedR.x, rotatedR.y, 0.0f));
        GLKVector2 movedL = {movedL3.x, movedL3.y};
        GLKVector2 movedC = {movedC3.x, movedC3.y};
        GLKVector2 movedR = {movedR3.x, movedR3.y};
        
        float centerLength = GLKVector2Distance(end, beg) * 0.9;
        float sideLength = GLKVector2Distance(end, beg) * 0.5;
        GLKVector2 leftEnd   = GLKVector2Add(end, GLKVector2MultiplyScalar(movedL, sideLength));
        GLKVector2 centerEnd = GLKVector2Add(end, GLKVector2MultiplyScalar(movedC, centerLength));
        GLKVector2 rightEnd  = GLKVector2Add(end, GLKVector2MultiplyScalar(movedR, sideLength));
        
        [self drawTree:context iteration:iteration - 1 beg:end end:leftEnd move:move * 0.5];
        [self drawTree:context iteration:iteration - 1 beg:end end:centerEnd move:move * 0.8];
        [self drawTree:context iteration:iteration - 1 beg:end end:rightEnd move:move * 0.5];
    }
}
- (IBAction)move:(UIButton *)sender {
    if(timer == nil)
    {
        startime = [NSDate date];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
    }
    else
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void)animationTick:(NSTimer *)sender
{
    const int size = 320 * [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size, size,
                                                 8, 4 * size,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    /**
     drawing
     */
    UIColor *uicolor = [UIColor colorWithRed:0.000 green:0.673 blue:0.185 alpha:1.000];
    CGColorRef color = uicolor.CGColor;
    CGContextSetFillColorWithColor(context, color);
    CGContextSetStrokeColorWithColor(context, color);
    
    float move = sin([[NSDate date] timeIntervalSinceDate:startime]);
    [self drawTree:context
         iteration:iterationCount
               beg:GLKVector2Make(size / 2, 0)
               end:GLKVector2Make(size / 2, size / 6)
              move:move * 10.0];
    
    /**
     *create image
     */
    CGImageRef imageFromContext = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageFromContext scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageFromContext);
    imageFromContext = NULL;
    
    CGContextRelease(context);
    
    canvas.image = image;
}

- (IBAction)generate:(id)sender
{
    const int size = 320 * [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size, size,
                                                 8, 4 * size,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    /**
     drawing
     */
    UIColor *uicolor = [UIColor colorWithRed:0.000 green:0.673 blue:0.185 alpha:1.000];
    CGColorRef color = uicolor.CGColor;
    CGContextSetFillColorWithColor(context, color);
    CGContextSetStrokeColorWithColor(context, color);
    ++iterationCount;
    [self drawTree:context iteration:iterationCount beg:GLKVector2Make(size / 2, 0) end:GLKVector2Make(size / 2, size / 6)];
    
    /**
     *create image
     */
    CGImageRef imageFromContext = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageFromContext scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageFromContext);
    imageFromContext = NULL;
    
    CGContextRelease(context);
    
    canvas.image = image;
}

@end
