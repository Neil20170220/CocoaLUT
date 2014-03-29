//
//  LUT.h
//  DropLUT
//
//  Created by Wil Gieseler on 12/15/13.
//  Copyright (c) 2013 Wil Gieseler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUTLattice.h"

@class LUTLattice;
@class LUT1D;

/**
 *  A three-dimensional color lookup table.
 */
@interface LUT : NSObject <NSCopying>

/**
 *  A lattice that represents the code values of the look up table.
 */
@property (readonly) LUTLattice *lattice;

/**
 *  Returns a new `LUT` by reading the a contents of a file represented by a file URL. It will automatically detect the type of LUT file format.
 *
 *  @param url A file URL.
 *
 *  @return A new `LUT` with the contents of url.
 */
+ (LUT *)LUTFromURL:(NSURL *)url;

/**
 *  Returns a new `LUT` with the specified lattice.
 *
 *  @param lattice A `LUTLattice` that represents the internal structure of the LUT.
 *
 *  @return A new `LUT` that uses lattice.
 */
+ (LUT *)LUTWithLattice:(LUTLattice *)lattice;

/**
 *  Returns a new `LUT` that maps input colors to output colors with no transformation.
 *
 *  @param size The length of one edge of the cube for the new LUT.
 *
 *  @return A new `LUT` with a lattice size of size.
 */
+ (LUT *)identityLutOfSize:(NSUInteger)size;

/**
 *  Returns a new `LUT` with a specified edge size. The LUT generated by trilinearly interpolating the receiver's lattice.
 *
 *  @param newSize The length of one edge of the cube for the new LUT.
 *
 *  @return A new LUT with a lattice of size newSize.
 */
- (LUT *)LUTByResizingToSize:(NSUInteger)newSize;


/**
 *  Returns a new `LUT` that is the original LUT combined with otherLUT.
 *
 *  @param otherLUT The LUT to apply to the current lut.
 *
 *  @return A new LUT with the same lattice size as self.lattice.size.
 */
- (LUT *)LUTByCombiningWithLUT:(LUT *)otherLUT;


- (LUT1D *)LUT1D;


/**
 *  Returns a Core Image filter that will apply the receiver's transformation in a particular color space.
 *
 *  @param colorSpace The desired color space to use on the filter. Pass `nil` to get a `CIFilter` of type `CIColorCube`.
 *
 *  @return A CIFilter of type `CIColorCubeWithColorSpace`.
 */
- (CIFilter *)coreImageFilterWithColorSpace:(CGColorSpaceRef)colorSpace;

/**
 *  Returns a Core Image filter that will apply the receiver's transformation in the color space of the main screen.
 *
 *  Due to limitations of Core Image, if the receiver has a lattice size larger than 64, the returned CIFilter will represent a scaled version of the LUT as scaled by LUTByResizingToSize:
 *
 *  @return A CIFilter of type `CIColorCubeWithColorSpace` or `CIColorCube`.
 */
- (CIFilter *)coreImageFilterWithCurrentColorSpace;

/**
 *  Returns a `CIImage` with the receiver's color transformation applied.
 *
 *  @param image      The input `CIImage` you wish transform.
 *  @param colorSpace The desired color space to use on the filter. Pass `nil` to apply the transformation without color management.
 *
 *  @return A `CIImage` with a `CIFilter` applied that represents the receiver's color transformation.
 */
- (CIImage *)processCIImage:(CIImage *)image withColorSpace:(CGColorSpaceRef)colorSpace;

#if TARGET_OS_IPHONE
/**
 *  Returns a `UIImage` with the receiver's color transformation applied.
 *
 *  @param image      The input `UIImage` you wish transform.
 *  @param colorSpace The desired color space to use on the filter. Pass `nil` to apply the transformation without color management.
 *
 *  @return A UIImage with the receiver's color transformation applied.
 */
- (UIImage *)processUIImage:(UIImage *)image withColorSpace:(CGColorSpaceRef)colorSpace;
#elif TARGET_OS_MAC
/**
 *  Returns an `NSImage` with the receiver's color transformation applied.
 *
 *  @param image      The input `NSImage` you wish transform.
 *  @param colorSpace The desired color space to use on the filter. Pass `nil` to apply the transformation without color management.
 *
 *  @return A `NSImage` with the receiver's color transformation applied.
 */
- (NSImage *)processNSImage:(NSImage *)image withColorSpace:(CGColorSpaceRef)colorSpace;
#endif


@end
