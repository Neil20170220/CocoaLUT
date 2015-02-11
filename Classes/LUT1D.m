//
//  LUT1D.m
//  Pods
//
//  Created by Greg Cotten and Wil Gieseler on 3/5/14.
//
//

#import "LUT1D.h"
#if defined(COCOAPODS_POD_AVAILABLE_VVLUT1DFilter)
#import <VVLUT1DFilter/VVLUT1DFilter.h>
#import <VVLUT1DFilter/VVLUT1DFilterWithColorSpace.h>
#endif

@interface LUT1D ()

@property (strong) NSMutableArray *redCurve;
@property (strong) NSMutableArray *greenCurve;
@property (strong) NSMutableArray *blueCurve;

@end

@implementation LUT1D

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.redCurve = [NSMutableArray array];
        self.greenCurve = [NSMutableArray array];
        self.blueCurve = [NSMutableArray array];
        
        NSData *redData = [aDecoder decodeObjectForKey:@"redCurveData"];
        NSData *greenData = [aDecoder decodeObjectForKey:@"greenCurveData"];
        NSData *blueData = [aDecoder decodeObjectForKey:@"blueCurveData"];
        
        if (redData.length != sizeof(double)*self.size || greenData.length != sizeof(double)*self.size || blueData.length != sizeof(double)*self.size) {
            return nil;
        }
        
        for (int i = 0; i < self.size; i++) {
            [self setColor:[LUTColor colorWithRed:((double *)redData.bytes)[i] green:((double *)greenData.bytes)[i] blue:((double *)blueData.bytes)[i]] r:i g:i b:i];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    double *redData = malloc(sizeof(double)*self.size);
    double *greenData = malloc(sizeof(double)*self.size);
    double *blueData = malloc(sizeof(double)*self.size);
    
    for (int i = 0; i < self.size; i++) {
        redData[i] = [self.redCurve[i] doubleValue];
        greenData[i] = [self.greenCurve[i] doubleValue];
        blueData[i] = [self.blueCurve[i] doubleValue];
    }
    
    [aCoder encodeObject:[NSData dataWithBytesNoCopy:redData length:sizeof(double)*self.size] forKey:@"redCurveData"];
    [aCoder encodeObject:[NSData dataWithBytesNoCopy:greenData length:sizeof(double)*self.size] forKey:@"greenCurveData"];
    [aCoder encodeObject:[NSData dataWithBytesNoCopy:blueData length:sizeof(double)*self.size] forKey:@"blueCurveData"];
}

+ (instancetype)LUT1DWithRedCurve:(NSMutableArray *)redCurve
                       greenCurve:(NSMutableArray *)greenCurve
                        blueCurve:(NSMutableArray *)blueCurve
                       lowerBound:(double)lowerBound
                       upperBound:(double)upperBound {
    return [[self alloc] initWithRedCurve:redCurve
                                       greenCurve:greenCurve
                                        blueCurve:blueCurve
                                       lowerBound:lowerBound
                                       upperBound:upperBound];
}

+ (instancetype)LUT1DWith1DCurve:(NSMutableArray *)curve1D
                      lowerBound:(double)lowerBound
                      upperBound:(double)upperBound {
    return [[self alloc] initWithRedCurve:[curve1D mutableCopy]
                                       greenCurve:[curve1D mutableCopy]
                                        blueCurve:[curve1D mutableCopy]
                                       lowerBound:lowerBound
                                       upperBound:upperBound];
}

- (instancetype)initWithRedCurve:(NSMutableArray *)redCurve
                      greenCurve:(NSMutableArray *)greenCurve
                       blueCurve:(NSMutableArray *)blueCurve
                      lowerBound:(double)lowerBound
                      upperBound:(double)upperBound {
    if (self = [super initWithSize:redCurve.count inputLowerBound:lowerBound inputUpperBound:upperBound]){

        self.redCurve = redCurve;
        self.greenCurve = greenCurve;
        self.blueCurve = blueCurve;
        if(redCurve.count != greenCurve.count || redCurve.count != blueCurve.count){
            @throw [NSException exceptionWithName:@"LUT1DCreationError" reason:[NSString stringWithFormat:@"Curves must be the same length. R:%d G:%d B:%d", (int)redCurve.count, (int)greenCurve.count, (int)blueCurve.count] userInfo:nil];
        }

    }
    return self;
}

+ (instancetype)LUTOfSize:(NSUInteger)size
          inputLowerBound:(double)inputLowerBound
          inputUpperBound:(double)inputUpperBound{
    NSMutableArray *blankCurve = [NSMutableArray array];
    for(int i = 0; i < size; i++){
        [blankCurve addObject:[NSNull null]];
    }
    return [LUT1D LUT1DWith1DCurve:blankCurve lowerBound:inputLowerBound upperBound:inputUpperBound];
}

- (void) LUTLoopWithBlock:( void ( ^ )(size_t r, size_t g, size_t b) )block{
    for(int index = 0; index < [self size]; index++){
        block(index, index, index);
    }
}

- (LUT *)LUTByCombiningWithLUT:(LUT *)otherLUT{
    LUT *combinedLUT;
    if(isLUT1D(otherLUT)){
        combinedLUT = [LUT1D LUTOfSize:self.size inputLowerBound:self.inputLowerBound inputUpperBound:self.inputUpperBound];
    }
    else{
        combinedLUT = [LUT3D LUTOfSize:MIN(MAX(otherLUT.size, self.size), COCOALUT_SUGGESTED_MAX_LUT3D_SIZE) inputLowerBound:self.inputLowerBound inputUpperBound:self.inputUpperBound];
    }
    [combinedLUT copyMetaPropertiesFromLUT:self];

    LUT *selfResizedLUT = [self LUTByResizingToSize:[combinedLUT size]];

    [combinedLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        LUTColor *startColor = [selfResizedLUT colorAtR:r g:g b:b];
        LUTColor *newColor = [otherLUT colorAtColor:startColor];
        [combinedLUT setColor:newColor r:r g:g b:b];
    }];

    return combinedLUT;
}

- (NSArray *)rgbCurveArray{
    return @[[self.redCurve mutableCopy], [self.greenCurve mutableCopy], [self.blueCurve mutableCopy]];
}

//convenience method for comparison purposes
- (NSMutableArray *)colorCurve{

    NSMutableArray *colorCurve = [NSMutableArray array];
    for(int i = 0; i < self.redCurve.count; i++){
        [colorCurve addObject:[LUTColor colorWithRed:[self.redCurve[i] doubleValue] green:[self.greenCurve[i] doubleValue] blue:[self.blueCurve[i] doubleValue]]];
    }
    return colorCurve;
}

- (void)setColor:(LUTColor *)color r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b{
    self.redCurve[r] = @(color.red);
    self.greenCurve[g] = @(color.green);
    self.blueCurve[b] = @(color.blue);
}

- (LUTColor *)colorAtR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b {
    return [LUTColor colorWithRed:[self.redCurve[r] doubleValue] green:[self.greenCurve[g] doubleValue] blue:[self.blueCurve[b] doubleValue]];
}

- (double)valueAtR:(NSUInteger)r{
    return [self.redCurve[r] doubleValue];
}
- (double)valueAtG:(NSUInteger)g{
    return [self.greenCurve[g] doubleValue];
}
- (double)valueAtB:(NSUInteger)b{
    return [self.blueCurve[b] doubleValue];
}

- (LUTColor *)colorAtColor:(LUTColor *)color{
    //no fear of extrapolating
    double redRemappedInterpolatedIndex = remapNoError(color.red, [self inputLowerBound], [self inputUpperBound], 0, [self size]-1);
    double greenRemappedInterpolatedIndex = remapNoError(color.green, [self inputLowerBound], [self inputUpperBound], 0, [self size]-1);
    double blueRemappedInterpolatedIndex = remapNoError(color.blue, [self inputLowerBound], [self inputUpperBound], 0, [self size]-1);

    return [self colorAtInterpolatedR:redRemappedInterpolatedIndex
                                    g:greenRemappedInterpolatedIndex
                                    b:blueRemappedInterpolatedIndex];
}

- (LUTColor *)colorAtInterpolatedR:(double)redPoint
                                 g:(double)greenPoint
                                 b:(double)bluePoint{

    if ((redPoint < 0   || redPoint     > self.size - 1) ||
        (greenPoint < 0 || greenPoint   > self.size - 1) ||
        (bluePoint < 0  || bluePoint    > self.size - 1)) {
        return [self colorAtExtrapolatedR:redPoint g:greenPoint b:bluePoint];
    }

    //red
    int redBottomIndex = floor(redPoint);
    int redTopIndex = ceil(redPoint);

    int greenBottomIndex = floor(greenPoint);
    int greenTopIndex = ceil(greenPoint);

    int blueBottomIndex = floor(bluePoint);
    int blueTopIndex = ceil(bluePoint);

    double interpolatedRedValue = lerp1d([self.redCurve[redBottomIndex] doubleValue], [self.redCurve[redTopIndex] doubleValue], redPoint - (double)redBottomIndex);
    double interpolatedGreenValue = lerp1d([self.greenCurve[greenBottomIndex] doubleValue], [self.greenCurve[greenTopIndex] doubleValue], greenPoint - (double)greenBottomIndex);
    double interpolatedBlueValue = lerp1d([self.blueCurve[blueBottomIndex] doubleValue], [self.blueCurve[blueTopIndex] doubleValue], bluePoint - (double)blueBottomIndex);

    return [LUTColor colorWithRed:interpolatedRedValue green:interpolatedGreenValue blue:interpolatedBlueValue];

}

- (LUTColor *)colorAtExtrapolatedR:(double)redPoint g:(double)greenPoint b:(double)bluePoint{
    LUTColor *increasingSlope = [[self colorAtR:self.size-1 g:self.size-1 b:self.size-1] colorBySubtractingColor:[self colorAtR:self.size-2 g:self.size-2 b:self.size-2]];
    double selfMaxIndex = self.size-1.0;
    LUTColor *selfColorAtMaxIndex = [self colorAtR:selfMaxIndex g:selfMaxIndex b:selfMaxIndex];

    LUTColor *decreasingSlope = [[self colorAtR:1 g:1 b:1] colorBySubtractingColor:[self colorAtR:0 g:0 b:0]];
    LUTColor *selfColorAtMinIndex = [self colorAtR:0 g:0 b:0];

    LUTColor *newColor = [LUTColor colorWithZeroes];

    if (redPoint > selfMaxIndex) {
        newColor.red = selfColorAtMaxIndex.red + (redPoint - selfMaxIndex)*increasingSlope.red;
    }
    else if (redPoint < 0){
        newColor.red = selfColorAtMinIndex.red + (redPoint)*decreasingSlope.red;
    }
    else{
        //interpolate instead
        int redBottomIndex = floor(redPoint);
        int redTopIndex = ceil(redPoint);
        newColor.red = lerp1d([self.redCurve[redBottomIndex] doubleValue], [self.redCurve[redTopIndex] doubleValue], redPoint - (double)redBottomIndex);
    }

    if (greenPoint > selfMaxIndex) {
        newColor.green = selfColorAtMaxIndex.green + (greenPoint - selfMaxIndex)*increasingSlope.green;
    }
    else if (greenPoint < 0){
        newColor.green = selfColorAtMinIndex.green + (greenPoint)*decreasingSlope.green;
    }
    else{
        int greenBottomIndex = floor(greenPoint);
        int greenTopIndex = ceil(greenPoint);
        newColor.green = lerp1d([self.greenCurve[greenBottomIndex] doubleValue], [self.greenCurve[greenTopIndex] doubleValue], greenPoint - (double)greenBottomIndex);
    }

    if (bluePoint > selfMaxIndex) {
        newColor.blue = selfColorAtMaxIndex.blue + (bluePoint - selfMaxIndex)*increasingSlope.blue;
    }
    else if (bluePoint < 0){
        newColor.blue = selfColorAtMinIndex.blue + (bluePoint)*decreasingSlope.blue;
    }
    else{
        int blueBottomIndex = floor(bluePoint);
        int blueTopIndex = ceil(bluePoint);
        newColor.blue = lerp1d([self.blueCurve[blueBottomIndex] doubleValue], [self.blueCurve[blueTopIndex] doubleValue], bluePoint - (double)blueBottomIndex);
    }

    return newColor;
    
}

+ (M13OrderedDictionary *)LUT1DSwizzleChannelsMethods{
    return M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"Averaged RGB":@(LUT1DSwizzleChannelsMethodAverageRGB)},
                                                                  @{@"Rec. 709 Weighted RGB":@(LUT1DSwizzleChannelsMethodRec709WeightedRGB)},
                                                                  @{@"Copy Red Channel":@(LUT1DSwizzleChannelsMethodRedCopiedToRGB)},
                                                                  @{@"Copy Green Channel":@(LUT1DSwizzleChannelsMethodGreenCopiedToRGB)},
                                                                  @{@"Copy Blue Channel":@(LUT1DSwizzleChannelsMethodBlueCopiedToRGB)}]);
}

- (instancetype)LUT1DBySwizzling1DChannelsWithMethod:(LUT1DSwizzleChannelsMethod)method{
    LUT1D *swizzledLUT = [LUT1D LUTOfSize:[self size] inputLowerBound:[self inputLowerBound] inputUpperBound:[self inputUpperBound]];
    [swizzledLUT copyMetaPropertiesFromLUT:self];

    [swizzledLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        if(method == LUT1DSwizzleChannelsMethodAverageRGB){
            LUTColor *color = [self colorAtR:r g:g b:b];
            double averageValue = (color.red+color.green+color.blue)/3.0;
            [swizzledLUT setColor:[LUTColor colorWithRed:averageValue green:averageValue blue:averageValue] r:r g:g b:b];
        }
        else if(method == LUT1DSwizzleChannelsMethodRec709WeightedRGB){
            LUTColor *color = [self colorAtR:r g:g b:b];
            //  ex: REC709 luma: 0.212636821677 R + 0.715182981841 G + 0.0721801964814 B
            double weightedValue = (0.2126*color.red+0.7152*color.green+0.0722*color.blue);
            [swizzledLUT setColor:[LUTColor colorWithRed:weightedValue green:weightedValue blue:weightedValue] r:r g:g b:b];
        }
        else if(method == LUT1DSwizzleChannelsMethodRedCopiedToRGB){
            LUTColor *color = [self colorAtR:r g:g b:b];
            [swizzledLUT setColor:[LUTColor colorWithRed:color.red green:color.red blue:color.red] r:r g:g b:b];
        }
        else if(method == LUT1DSwizzleChannelsMethodGreenCopiedToRGB){
            LUTColor *color = [self colorAtR:r g:g b:b];
            [swizzledLUT setColor:[LUTColor colorWithRed:color.green green:color.green blue:color.green] r:r g:g b:b];
        }
        else if(method == LUT1DSwizzleChannelsMethodBlueCopiedToRGB){
            LUTColor *color = [self colorAtR:r g:g b:b];
            [swizzledLUT setColor:[LUTColor colorWithRed:color.blue green:color.blue blue:color.blue] r:r g:g b:b];
        }
    }];

    return swizzledLUT;
}

- (instancetype)LUT1DByReversingWithStrictness:(BOOL)strictness
                         autoAdjustInputBounds:(BOOL)autoAdjustInputBounds{
    if(![self isReversibleWithStrictness:strictness]){
        return nil;
    }

    LUT1D *usedLUT = self.size >= 2048 ? self : [self LUTByResizingToSize:2048];

    NSArray *rgbCurves = @[usedLUT.redCurve, usedLUT.greenCurve, usedLUT.blueCurve];

    NSMutableArray *newRGBCurves = [[NSMutableArray alloc] init];

    double newLowerBound = self.minimumOutputValue;
    double newUpperBound = self.maximumOutputValue;

    for(NSMutableArray *curve in rgbCurves){
        NSMutableArray *newCurve = [[NSMutableArray alloc] init];

        double minValue = [[curve valueForKeyPath:@"@min.self"] doubleValue];
        double maxValue = [[curve valueForKeyPath:@"@max.self"] doubleValue];

        int lastJ = 0;
        for(int i = 0; i < usedLUT.size; i++){
            double remappedIndex = remap(i, 0, usedLUT.size-1, newLowerBound, newUpperBound);

            if (remappedIndex <= minValue){
                [newCurve addObject:@(usedLUT.inputLowerBound)];
            }
            else if(remappedIndex >= maxValue){
                [newCurve addObject:@(usedLUT.inputUpperBound)];
            }
            else{
                for(int j = lastJ; j < usedLUT.size; j++){
                    double currentValue = [curve[j] doubleValue];
                    if (currentValue > remappedIndex){
                        double previousValue = [curve[j-1] doubleValue]; //smaller or equal to remappedIndex
                        double lowerValue = remap(j-1, 0, usedLUT.size-1, usedLUT.inputLowerBound, usedLUT.inputUpperBound);
                        double higherValue = remap(j, 0, usedLUT.size-1, usedLUT.inputLowerBound, usedLUT.inputUpperBound);
                        [newCurve addObject:@(lerp1d(lowerValue, higherValue,(remappedIndex - previousValue)/(currentValue - previousValue)))];
                        lastJ = j;
                        break;
                    }
                }
            }

        }

        [newRGBCurves addObject:[NSMutableArray arrayWithArray:newCurve]];
    }

    //ease edges
//    if(![self isReversibleWithStrictness:YES]){
//        for (NSMutableArray *curve in newRGBCurves){
//            curve[0] = @(clampLowerBound([curve[1] doubleValue] - (([curve[2] doubleValue] - [curve[1] doubleValue])), self.inputLowerBound));
//            curve[self.size - 1] = @(clampUpperBound([curve[self.size-2] doubleValue] + (([curve[self.size-2] doubleValue] - [curve[self.size-3] doubleValue])), self.inputUpperBound));
//        }
//    }


    LUT1D *newLUT = [LUT1D LUT1DWithRedCurve:newRGBCurves[0]
                                  greenCurve:newRGBCurves[1]
                                   blueCurve:newRGBCurves[2]
                                  lowerBound:newLowerBound
                                  upperBound:newUpperBound];
    [newLUT copyMetaPropertiesFromLUT:self];

    if (autoAdjustInputBounds && (self.inputLowerBound < newLUT.inputLowerBound || self.inputUpperBound > newLUT.inputUpperBound)){
        //if the original LUT encompasses a greater bound in some way, make the output LUT fill that bound too
        double inputLowerBound = MIN(self.inputLowerBound, newLUT.inputLowerBound);
        double inputUpperBound = MAX(self.inputUpperBound, newLUT.inputUpperBound);

        newLUT = [newLUT LUTByChangingInputLowerBound:inputLowerBound inputUpperBound:inputUpperBound];
    }

    if (self.size != newLUT.size) {
        newLUT = [newLUT LUTByResizingToSize:self.size];
    }

    return newLUT;
}

- (BOOL)isReversibleWithStrictness:(BOOL)strict{
    BOOL isIncreasing = YES;
    BOOL isDecreasing = YES;

    NSArray *rgbCurves = @[self.redCurve, self.greenCurve, self.blueCurve];

    for(NSMutableArray *curve in rgbCurves){
        double lastValue = [curve[0] doubleValue];
        for(int i = 1; i < [curve count]; i++){
            double currentValue = [curve[i] doubleValue];
            if(currentValue <= lastValue){//make <= to be very strict
                if(strict || currentValue != lastValue){
                    isIncreasing = NO;
                }
            }
            if(currentValue >= lastValue){//make <= to be very strict
                if(strict || currentValue != lastValue){
                    isDecreasing = NO;
                }
            }
            lastValue = currentValue;
        }
    }
    return isIncreasing;
}

- (bool)equalsLUT:(LUT *)comparisonLUT{
    if(isLUT3D(comparisonLUT)){
        return NO;
    }
    else{
        //it's LUT1D
        if([self size] != [comparisonLUT size]){
            return NO;
        }
        else{
            return [[self colorCurve] isEqualToArray:[(LUT1D *)comparisonLUT colorCurve]];
        }
    }
}

- (LUT3D *)LUT3DOfSize:(NSUInteger)size {
    //the size parameter is out of desperation - we can't be making 1024x cubes can we?
    LUT1D *resized1DLUT = [self LUTByResizingToSize:size];


    LUT3D *newLUT = [LUT3D LUTOfSize:size inputLowerBound:[self inputLowerBound] inputUpperBound:[self inputUpperBound]];
    [newLUT copyMetaPropertiesFromLUT:self];

    [newLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        [newLUT setColor:[resized1DLUT colorAtR:r g:g b:b] r:r g:g b:b];
    }];

    return newLUT;
}

- (NSData *)lutDataRGBAf{
    size_t dataSize = sizeof(float)*4*self.size;
    float* lutArray = (float *)malloc(dataSize);
    for (int i = 0; i < self.size; i++) {
        LUTColor *color = [self colorAtR:i g:i b:i];
        lutArray[i*4] = clamp(color.red, 0, 1);
        lutArray[i*4+1] = clamp(color.green, 0, 1);
        lutArray[i*4+2] = clamp(color.blue, 0, 1);
        lutArray[i*4+3] = 1.0;
    }

    return [NSData dataWithBytesNoCopy:lutArray length:dataSize];
}

- (CIFilter *)coreImageFilterWithColorSpace:(CGColorSpaceRef)colorSpace{
    #if defined(COCOAPODS_POD_AVAILABLE_VVLUT1DFilter)
    LUT1D *usedLUT = self.size>COCOALUT_MAX_VVLUT1DFILTER_SIZE?[self LUTByResizingToSize:COCOALUT_MAX_VVLUT1DFILTER_SIZE]:self;

//    if (usedLUT.inputUpperBound - usedLUT.inputLowerBound != 1.0 && usedLUT.inputUpperBound - usedLUT.inputLowerBound < 2.0) {
//        usedLUT = [usedLUT LUTByChangingInputLowerBound:0 inputUpperBound:1];
//    }

    if (self.inputLowerBound != 0 || self.inputUpperBound != 1) {
        NSLog(@"CocoaLUT: You should only be seeing this message if you are applying a CI LUT filter to a normalized scene-linear image - make sure to change the input bounds to 0-1 if you aren't using normalized scene-linear data.");
    }

    NSData *inputData = [usedLUT lutDataRGBAf];

    CIFilter *lutFilter;

    if (colorSpace) {
        lutFilter = [CIFilter filterWithName:@"VVLUT1DFilterWithColorSpace"];
        [lutFilter setValue:(__bridge id)(colorSpace) forKey:@"inputColorSpace"];
    }
    else {
        lutFilter = [CIFilter filterWithName:@"VVLUT1DFilter"];
    }

    [lutFilter setValue:inputData forKey:@"inputData"];
    [lutFilter setValue:@(usedLUT.size) forKey:@"inputSize"];

    return lutFilter;

    #else
    return [[self LUT3DOfSize:MIN(self.size, COCOALUT_SUGGESTED_MAX_LUT3D_SIZE)] coreImageFilterWithColorSpace:colorSpace];
    #endif
}

- (id)copyWithZone:(NSZone *)zone{
    LUT1D *copiedLUT = [super copyWithZone:zone];
    copiedLUT.redCurve = [self.redCurve mutableCopyWithZone:zone];
    copiedLUT.greenCurve = [self.greenCurve mutableCopyWithZone:zone];
    copiedLUT.blueCurve = [self.blueCurve mutableCopyWithZone:zone];

    return copiedLUT;
}

@end
