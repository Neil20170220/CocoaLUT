//
//  LUTColorSpace.h
//  Pods
//
//  Created by Greg Cotten on 4/2/14.
//
//

#import <Foundation/Foundation.h>
#import "CocoaLUT.h"
#import "LUTColorSpaceWhitePoint.h"

@class LUTColorTransferFunction;

@interface LUTColorSpace : NSObject <NSCopying>

@property (strong) LUTColorSpaceWhitePoint *defaultWhitePoint;
@property (assign) double redChromaticityX;
@property (assign) double redChromaticityY;
@property (assign) double greenChromaticityX;
@property (assign) double greenChromaticityY;
@property (assign) double blueChromaticityX;
@property (assign) double blueChromaticityY;

@property (assign) BOOL forcesNPM;
@property (assign) double forwardFootlambertCompensation;

@property (strong) NSString *name;


+ (instancetype)LUTColorSpaceWithDefaultWhitePoint:(LUTColorSpaceWhitePoint *)whitePoint
                                  redChromaticityX:(double)redChromaticityX
                                  redChromaticityY:(double)redChromaticityY
                                greenChromaticityX:(double)greenChromaticityX
                                greenChromaticityY:(double)greenChromaticityY
                                 blueChromaticityX:(double)blueChromaticityX
                                 blueChromaticityY:(double)blueChromaticityY
                                              name:(NSString *)name;
+ (NSArray *)knownColorSpaces;

+ (instancetype)rec709ColorSpace;
+ (instancetype)adobeRGBColorSpace;
+ (instancetype)dciP3ColorSpace;
+ (instancetype)rec2020ColorSpace;
+ (instancetype)alexaWideGamutColorSpace;
+ (instancetype)sGamut3CineColorSpace;
+ (instancetype)sGamutColorSpace;
+ (instancetype)acesGamutColorSpace;
+ (instancetype)xyzColorSpace;




@end
