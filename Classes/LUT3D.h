//
//  LUT3D.h
//  DropLUT
//
//  Created by Wil Gieseler on 12/15/13.
//  Copyright (c) 2013 Wil Gieseler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUTColor.h"
#import "LUT.h"
#import <M13OrderedDictionary/M13OrderedDictionary.h>

@class LUTColor;
@class LUT1D;


typedef NS_ENUM(NSInteger, LUTMonoConversionMethod) {
    LUTMonoConversionMethodAverageRGB,
    LUTMonoConversionMethodRec709WeightedRGB,
    LUTMonoConversionMethodRedCopiedToRGB,
    LUTMonoConversionMethodGreenCopiedToRGB,
    LUTMonoConversionMethodBlueCopiedToRGB
};

/**
 *  Represents a lattice of `LUTColor` objects that make up a 3D lookup table.
 */
@interface LUT3D : LUT

- (instancetype)LUT3DByApplyingFalseColor;
- (instancetype)LUT3DByExtractingColorShiftWithReverseStrictnessType:(LUT1DReverseStrictnessType)strictnessType;
- (instancetype)LUT3DByExtractingColorShiftContrastReferredWithReverseStrictnessType:(LUT1DReverseStrictnessType)strictnessType;
- (instancetype)LUT3DByExtractingContrastOnly;
- (instancetype)LUT3DByConvertingToMonoWithConversionMethod:(LUTMonoConversionMethod)conversionMethod;
- (instancetype)LUT3DBySwizzling1DChannelsWithMethod:(LUT1DSwizzleChannelsMethod)method
                                      strictnessType:(LUT1DReverseStrictnessType)strictnessType;

- (instancetype)LUT3DByApplyingColorMatrixColumnMajorM00:(double)m00
                                                     m01:(double)m01
                                                     m02:(double)m02
                                                     m10:(double)m10
                                                     m11:(double)m11
                                                     m12:(double)m12
                                                     m20:(double)m20
                                                     m21:(double)m21
                                                     m22:(double)m22;
- (LUT1D *)LUT1D;

- (BOOL)is1DLUT;

- (NSMutableArray *)latticeArrayCopy;


+ (M13OrderedDictionary *)LUTMonoConversionMethods;



@end
