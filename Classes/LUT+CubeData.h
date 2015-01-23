//
//  LUT+CubeData.h
//
//
//  Created by Bruce Johnson on 1/15/15.
//
//

#import "LUT3D.h"


/**
 Category to allow a single CIFilter instantace to use multiple LUT3Ds
 
	 //CIColorCube filter set up in a controller class:
	 CIFilter *_colorCubeFilter = [CIFilter filterWithName:@"CIColorCube"];

	 //multiple LUT3D's set up
	 LUT3D *lutOne = [LUT3D LUTFromURL: pathURL1];
	 LUT3D *lutTwo = [LUT3D LUTFromURL: pathURL2];

	 NSData *cubeData = nil;
	 size_t size;

	if (useLut1) {
		size = [self.lutOne LUTCubeData: &cubeData];
	} else {
		size = [self.lutTwo LUTCubeData: &cubeData];
	}

	[_colorCubeFilter setValue: @(size) forKey: @"inputCubeDimension"];
	[_colorCubeFilter setValue: cubeData forKey: @"inputCubeData"];
 
 **/

@interface LUT3D (CubeData)

- (size_t) LUTCubeData: (NSData **)data;

@end
