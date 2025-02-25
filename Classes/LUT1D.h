//
//  LUT1D.h
//  Pods
//
//  Created by Greg Cotten and Wil Gieseler on 3/5/14.
//
//

#import <Foundation/Foundation.h>
#import "CocoaLUT.h"
#import "LUT.h"
#import <M13OrderedDictionary/M13OrderedDictionary.h>

@class LUTColor;
@class LUT3D;





/**
 *  A one-dimensional color lookup table that is represented by three channel curves.
 */
@interface LUT1D : LUT


@property (assign) BOOL allowsExtrapolation;

/**
 *  Initializes and returns a 1D LUT with the specified channel curves.
 *
 *  An exception will be raised unless all three curves contain the same number of points.
 *
 *  @param redCurve   An array of `NSNumber` instances representing the brightness of the red channel curve. Values should be between 0 and 1.
 *  @param greenCurve An array of `NSNumber` instances representing the brightness of the green channel curve. Values should be between 0 and 1.
 *  @param blueCurve  An array of `NSNumber` instances representing the brightness of the blue channel curve. Values should be between 0 and 1.
 *
 *  @return A newly initialized 1D LUT.
 */
+ (instancetype)LUT1DWithRedCurve:(NSArray *)redCurve
                       greenCurve:(NSArray *)greenCurve
                        blueCurve:(NSArray *)blueCurve
                       lowerBound:(double)lowerBound
                       upperBound:(double)upperBound;

+ (instancetype)LUT1DWith1DCurve:(NSArray *)curve1D
                      lowerBound:(double)lowerBound
                      upperBound:(double)upperBound;

- (LUTColor *)colorAtExtrapolatedR:(double)redPoint g:(double)greenPoint b:(double)bluePoint;


- (BOOL)isReversibleWithStrictnessType:(LUT1DReverseStrictnessType)strictness;
- (instancetype)LUT1DByReversingWithStrictnessType:(LUT1DReverseStrictnessType)strictnessType
                             autoAdjustInputBounds:(BOOL)autoAdjustInputBounds;

- (instancetype)LUT1DBySwizzling1DChannelsWithMethod:(LUT1DSwizzleChannelsMethod)method;

+ (M13OrderedDictionary *)LUT1DSwizzleChannelsMethods;

/**
 *  Initializes a newly allocated 1D LUT with the specified channel curves.
 *
 *  An exception will be raised unless all three curves contain the same number of points.
 *
 *  @param redCurve   An array of `NSNumber` instances representing the brightness of the red channel curve. Values should be between 0 and 1.
 *  @param greenCurve An array of `NSNumber` instances representing the brightness of the green channel curve. Values should be between 0 and 1.
 *  @param blueCurve  An array of `NSNumber` instances representing the brightness of the blue channel curve. Values should be between 0 and 1.
 *
 *  @return A newly initialized 1D LUT.
 */
- (instancetype)initWithRedCurve:(NSArray *)redCurve
                      greenCurve:(NSArray *)greenCurve
                       blueCurve:(NSArray *)blueCurve
                      lowerBound:(double)lowerBound
                      upperBound:(double)upperBound;

//convenience method for comparison purposes
- (NSMutableArray *)colorCurve;

- (NSArray *)rgbCurveArray;

- (double)valueAtR:(NSUInteger)r;
- (double)valueAtG:(NSUInteger)g;
- (double)valueAtB:(NSUInteger)b;

- (instancetype)LUT1DByMakingReversibleWithReversibility:(LUT1DReverseStrictnessType)desiredReversibility;
- (LUT1DReverseStrictnessType)reversibility;



/**
 *  Generates a 3D LUT that represents an approximation of the transformation applied by the channel curves.
 *
 *  @param size The edge length of the 3D LUT cube.
 *
 *  @return A new `LUT`.
 */
- (LUT3D *)LUT3DOfSize:(NSUInteger)size;


@end
