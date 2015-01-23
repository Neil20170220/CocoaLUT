//
//  LUT+CubeData.m
//
//
//  Created by Bruce Johnson on 1/15/15.
//
//

#import "LUT+CubeData.h"
#import "LUT.h"
#import <CocoaLUT/CocoaLUT.h>

@implementation LUT3D (CubeData)

- (size_t) LUTCubeData: (NSData **)returnData
{
	
	NSUInteger sizeOfColorCubeFilter = clamp([self size], 0, COCOALUT_MAX_CICOLORCUBE_SIZE);
	LUT3D *used3DLUT = [LUTAsLUT3D(self, sizeOfColorCubeFilter) LUTByChangingInputLowerBound:0.0 inputUpperBound:1.0];
	
	size_t size = [used3DLUT size];
	size_t cubeDataSize = size * size * size * sizeof (float) * 4;
	float *cubeData = (float *) malloc (cubeDataSize);
	
	[used3DLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
		LUTColor *transformedColor = [used3DLUT colorAtR:r g:g b:b];
		
		size_t offset = 4*(b*size*size + g*size + r);
		
		cubeData[offset]   = (float)transformedColor.red;
		cubeData[offset+1] = (float)transformedColor.green;
		cubeData[offset+2] = (float)transformedColor.blue;
		cubeData[offset+3] = 1.0f;
	}];
	
	*returnData = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];

	return size;
}

@end
