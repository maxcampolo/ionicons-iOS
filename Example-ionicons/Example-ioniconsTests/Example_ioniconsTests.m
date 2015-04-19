//
//  Example_ioniconsTests.m
//  Example-ioniconsTests
//
//  Created by ds on 10/30/13.
//  Copyright (c) 2013 TapTemplate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "allIconCodes.h"
#import "IonIcons.h"
#import "FontInspector.h"
@import CoreText;
@import Accelerate;

@interface IonIcons()
// expose a private method:
+(UIColor*)defaultColor;
@end

@interface Example_ioniconsTests : XCTestCase
@end

@implementation Example_ioniconsTests

- (void)testForValidFontName
{
    UIFont* fontName = [IonIcons fontWithSize:15.0];
    XCTAssertNotNil(fontName);
}

/**
 *  Enumerate all of the icon names provided in ionicons-codes.h and ensure that they actually corresond
 *  to a glyph in the icon font. allIconCodes() is a an array autogenerated by a Run Script build phase
 *  populated with all of the icon names.
 */
- (void)testIconNamesReturnGlyphs {
    NSArray *iconNamesArray = allIconCodes();
    UIFont *font = [IonIcons fontWithSize:10.0];
    
    for (NSString *iconName in iconNamesArray) {
        BOOL exists = [FontInspector doGlyphsReferencedInString:iconName existInFont:font];
        XCTAssertTrue(exists,
                      @"This iconName references a character that doesn't exist in this font: %@", iconName);
    }
}

- (void)testThatImageIsRenderedAtSize {
    CGFloat iconSize = 32.0;
    UIImage* img = [self imageWithIconSizeTheSameAsImageSize:iconSize];
    XCTAssertEqual(img.size.width, iconSize);
    XCTAssertEqual(img.size.height, iconSize);
}

- (void)testThatIconAndImageSizeAreDistinct {
    CGFloat iconSize = 32.0;
    CGFloat imageSize = 45.0;
    UIImage* imgWithImageSize = [self imageWithIconSize:iconSize imageSizeWithEqualHeightAndWidthLength:imageSize];
    XCTAssertTrue(imgWithImageSize.size.width == imageSize &&
                  imgWithImageSize.size.height == imageSize);
}

- (void)testThatSizeAllowsNonSquare {
    CGFloat iconSize = 32.0;
    CGFloat imageWidth = 44.0;
    CGFloat imageHeight = 54.0;
    UIImage* imgWithDifferentHeightAndWidth = [self imageWithIconSize:iconSize
                                                            imageSize:CGSizeMake(imageWidth, imageHeight)];
    XCTAssertEqual(imgWithDifferentHeightAndWidth.size.width, imageWidth);
    XCTAssertEqual(imgWithDifferentHeightAndWidth.size.height, imageHeight);
}

- (void)testImageForNonNil {
    XCTAssertNotNil([self imageWithIconSizeTheSameAsImageSize:32.0]);
    XCTAssertNotNil([self imageWithIconSize:32.0 imageSizeWithEqualHeightAndWidthLength:45.0]);
    XCTAssertNotNil([self imageWithIconSize:32.0 imageSize:CGSizeMake(44.0, 54.0)]);
}

- (void)testImageColor {
    UIImage* imgOfSize = [self imageWithColor:[UIColor redColor]];
    XCTAssertFalse([self checkImage:imgOfSize forColor:[UIColor greenColor]]);
    XCTAssertTrue([self checkImage:imgOfSize forColor:[UIColor redColor]]);
    
    UIImage* iconOfImgSize = [self imageWithColor:[UIColor redColor] imageSize:CGSizeMake(32.0, 43.0)];
    XCTAssertFalse([self checkImage:imgOfSize forColor:[UIColor greenColor]]);
    XCTAssertTrue([self checkImage:iconOfImgSize forColor:[UIColor redColor]]);
}

- (void)testDefaultImageColor {
    UIImage* iconWithNilColor = [self imageWithColor:nil imageSize:CGSizeMake(12.0, 12.0)];
    XCTAssertTrue([self checkImage:iconWithNilColor forColor:[IonIcons defaultColor]]);
}

#pragma mark - Utility

/**
 *  Look through an image's pixels for a given color.
 *  Return when we've reached found the first matching pixel or reached the end.
 */
- (BOOL)checkImage:(UIImage*)image forColor:(UIColor*)color
{
    CGFloat r,g,b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    BOOL match = NO;
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    unsigned char *rawData = (unsigned char*) calloc(height * width * bytesPerPixel, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    for (NSUInteger x = 0 ; x < width ; x++) {
        for (NSUInteger y = 0; y < height; y++) {
            
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
            CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
            CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
            
            if (red == r && green == g & blue == b) {
                match = YES;
                break;
            }
            
            byteIndex += bytesPerPixel;
        }
    }
    
    free(rawData);
    
    return match;
}

- (UIImage*)imageWithIconSizeTheSameAsImageSize:(CGFloat) size {
    return [IonIcons imageWithIcon:ion_alert size:size color:[UIColor whiteColor]];
}

- (UIImage*)imageWithIconSize:(CGFloat)iconSize imageSize:(CGSize)imageSize {
    return [IonIcons imageWithIcon:ion_alert iconColor:[UIColor whiteColor] iconSize:iconSize imageSize:imageSize];
}

- (UIImage*)imageWithIconSize:(CGFloat)iconSize imageSizeWithEqualHeightAndWidthLength:(CGFloat)imageSize {
    return [IonIcons imageWithIcon:ion_alert iconColor:[UIColor whiteColor] iconSize:iconSize imageSize:CGSizeMake(imageSize, imageSize)];
}

- (UIImage*)imageWithColor:(UIColor*)color {
    return [IonIcons imageWithIcon:ion_alert size:32.0 color:color];
}

- (UIImage*)imageWithColor:(UIColor*)color imageSize:(CGSize)imgSize {
    return [IonIcons imageWithIcon:ion_alert iconColor:color iconSize:32.0 imageSize:imgSize];
}

@end
