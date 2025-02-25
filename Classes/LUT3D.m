//
//  LUT3D.m
//  DropLUT
//
//  Created by Wil Gieseler on 12/15/13.
//  Copyright (c) 2013 Wil Gieseler. All rights reserved.
//

#import "LUT3D.h"
#import <CoreImage/CoreImage.h>

@interface LUT3D()
@property NSMutableArray *latticeArray;
@end

@implementation LUT3D

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.latticeArray = [LUT3D blankLatticeArrayOfSize:self.size];
        NSData *latticeData = [aDecoder decodeObjectForKey:@"latticeData"];
        
        if (latticeData.length != sizeof(double)*3*self.size*self.size*self.size) {
            return nil;
        }
        
        double *dataBytes = (double *)latticeData.bytes;
        
        for (int i = 0; i < 3*self.size*self.size*self.size; i+=3) {
            int currentCubeIndex = i/3;
            int redIndex = currentCubeIndex % self.size;
            int greenIndex = ((currentCubeIndex % (self.size * self.size)) / (self.size) );
            int blueIndex = currentCubeIndex / (self.size * self.size);
            
            [self setColor:[LUTColor colorWithRed:dataBytes[i] green:dataBytes[i+1] blue:dataBytes[i+2]] r:redIndex g:greenIndex b:blueIndex];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    double *latticeData = malloc(sizeof(double)*3*self.size*self.size*self.size);
    
    for (int i = 0; i < 3*self.size*self.size*self.size; i+=3) {
        int currentCubeIndex = i/3;
        int redIndex = currentCubeIndex % self.size;
        int greenIndex = ((currentCubeIndex % (self.size * self.size)) / (self.size) );
        int blueIndex = currentCubeIndex / (self.size * self.size);
        
        LUTColor *color = [self colorAtR:redIndex g:greenIndex b:blueIndex];
        latticeData[i] = color.red;
        latticeData[i+1] = color.green;
        latticeData[i+2] = color.blue;
    }
    
    [aCoder encodeObject:[NSData dataWithBytesNoCopy:latticeData length:sizeof(double)*3*self.size*self.size*self.size] forKey:@"latticeData"];
}

- (instancetype)initWithSize:(NSUInteger)size
             inputLowerBound:(double)inputLowerBound
             inputUpperBound:(double)inputUpperBound
                latticeArray:(NSMutableArray *)latticeArray{
    if (self = [super initWithSize:size inputLowerBound:inputLowerBound inputUpperBound:inputUpperBound]) {
        self.latticeArray = latticeArray;
    }
    return self;
}

+ (instancetype)LUTOfSize:(NSUInteger)size
          inputLowerBound:(double)inputLowerBound
          inputUpperBound:(double)inputUpperBound{
    return [[self alloc] initWithSize:size
                              inputLowerBound:inputLowerBound
                              inputUpperBound:inputUpperBound
                                 latticeArray:[LUT3D blankLatticeArrayOfSize:size]];
}

+ (instancetype)LUTFromBitmapData:(NSData *)data
                      LUTDataType:(LUTDataType)lutDataType
                  inputLowerBound:(double)inputLowerBound
                  inputUpperBound:(double)inputUpperBound{
    if (lutDataType == LUTDataTypeRGBAf) {
        LUT3D *lut3D = [LUT3D LUTOfSize:cbrt((data.length/sizeof(float))/4) inputLowerBound:inputLowerBound inputUpperBound:inputUpperBound];

        float *bitmap = (float *)data.bytes;

        for (int i = 0; i < 4*lut3D.size*lut3D.size*lut3D.size; i+=4) {
            int currentCubeIndex = i/4;
            int redIndex = currentCubeIndex % lut3D.size;
            int greenIndex = ((currentCubeIndex % (lut3D.size * lut3D.size)) / (lut3D.size) );
            int blueIndex = currentCubeIndex / (lut3D.size * lut3D.size);

            [lut3D setColor:[LUTColor colorWithRed:bitmap[i] green:bitmap[i+1] blue:bitmap[i+2]] r:redIndex g:greenIndex b:blueIndex];
        }


        return lut3D;

    }
    else if (lutDataType == LUTDataTypeRGBd){
        LUT3D *lut3D = [LUT3D LUTOfSize:cbrt((data.length/sizeof(double))/3) inputLowerBound:inputLowerBound inputUpperBound:inputUpperBound];

        double *bitmap = (double *)data.bytes;

        for (int i = 0; i < 3*lut3D.size*lut3D.size*lut3D.size; i+=3) {
            int currentCubeIndex = i/3;
            int redIndex = currentCubeIndex % lut3D.size;
            int greenIndex = ((currentCubeIndex % (lut3D.size * lut3D.size)) / (lut3D.size) );
            int blueIndex = currentCubeIndex / (lut3D.size * lut3D.size);

            [lut3D setColor:[LUTColor colorWithRed:bitmap[i] green:bitmap[i+1] blue:bitmap[i+2]] r:redIndex g:greenIndex b:blueIndex];
        }

        return lut3D;
    }
    else if (lutDataType == LUTDataTypeRGBf){
        LUT3D *lut3D = [LUT3D LUTOfSize:cbrt((data.length/sizeof(float))/3) inputLowerBound:inputLowerBound inputUpperBound:inputUpperBound];

        float *bitmap = (float *)data.bytes;

        for (int i = 0; i < 3*lut3D.size*lut3D.size*lut3D.size; i+=3) {
            int currentCubeIndex = i/3;
            int redIndex = currentCubeIndex % lut3D.size;
            int greenIndex = ((currentCubeIndex % (lut3D.size * lut3D.size)) / (lut3D.size) );
            int blueIndex = currentCubeIndex / (lut3D.size * lut3D.size);

            [lut3D setColor:[LUTColor colorWithRed:bitmap[i] green:bitmap[i+1] blue:bitmap[i+2]] r:redIndex g:greenIndex b:blueIndex];
        }
        
        return lut3D;
    }
    else{
        return nil;
    }
}

+ (instancetype)LUT3DFromFalseColorWithSize:(NSUInteger)size{
    LUT3D *falseColorLUT = [LUT3D LUTOfSize:size inputLowerBound:0 inputUpperBound:1];
    
    LUTColor *purple = [LUTColor colorWithSystemColor:[SystemColor purpleColor]];
    LUTColor *blue = [LUTColor colorWithSystemColor:[SystemColor blueColor]];
    LUTColor *green = [LUTColor colorWithSystemColor:[SystemColor greenColor]];
    LUTColor *pink = [LUTColor colorWithSystemColor:[SystemColor colorWithRed:1.0 green:.753 blue:.796 alpha:1.0]];
    LUTColor *yellow = [LUTColor colorWithSystemColor:[SystemColor yellowColor]];
    LUTColor *red = [LUTColor colorWithSystemColor:[SystemColor redColor]];
    
    
    [falseColorLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        double lum = [[falseColorLUT identityColorAtR:r g:g b:b] luminanceRec709];
        
        LUTColor *falseColor = [LUTColor colorWithRed:lum green:lum blue:lum];
        
        if (lum <= .025) {
            falseColor = purple;
        }
        else if (lum > .025 && lum <= .04){
            falseColor = blue;
        }
        else if (lum >= .38 && lum <= .42){
            falseColor = green;
        }
        else if (lum >= .52 && lum <= .56){
            falseColor = pink;
        }
        else if (lum >= .97 && lum <= .99){
            falseColor = yellow;
        }
        else if (lum > .99 && lum <= .100){
            falseColor = red;
        }
        
        [falseColorLUT setColor:falseColor r:r g:g b:b];
    }];
    
    return falseColorLUT;
}

- (instancetype)LUT3DByApplyingFalseColor{
    return (LUT3D *)[self LUTByCombiningWithLUT:[LUT3D LUT3DFromFalseColorWithSize:self.size]];
}

- (void) LUTLoopWithBlock:( void ( ^ )(size_t r, size_t g, size_t b) )block{
    dispatch_apply([self size], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , ^(size_t r){
        dispatch_apply([self size], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , ^(size_t g){
            for (int b = 0; b < [self size]; b++) {
                block(r, g, b);
            }
        });
    });
}

- (LUT *)LUTByCombiningWithLUT:(LUT *)otherLUT {
    NSUInteger outputSize = MAX(clampUpperBound(MAX(self.size, otherLUT.size), COCOALUT_SUGGESTED_MAX_LUT3D_SIZE), self.size);
    double usedInputLowerBound = MAX(self.inputLowerBound, otherLUT.inputLowerBound);
    double usedInputUpperBound = MIN(self.inputUpperBound, otherLUT.inputUpperBound);
    
    LUT3D *newLUT = [LUT3D LUTOfSize:outputSize inputLowerBound:usedInputLowerBound inputUpperBound:usedInputUpperBound];
    [newLUT copyMetaPropertiesFromLUT:self];
    
    [newLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        LUTColor *startColor = [self colorAtColor:[newLUT identityColorAtR:r g:g b:b]];
        LUTColor *newColor = [otherLUT colorAtColor:startColor];
        [newLUT setColor:newColor r:r g:g b:b];
    }];
    
    return newLUT;
}

- (LUT *)LUTByLerpingToLUT:(LUT *)otherLUT
                lerpAmount:(double)lerpAmount{
    NSUInteger outputSize = MAX(clampUpperBound(MAX(self.size, otherLUT.size), COCOALUT_SUGGESTED_MAX_LUT3D_SIZE), self.size);
    double usedInputLowerBound = MAX(self.inputLowerBound, otherLUT.inputLowerBound);
    double usedInputUpperBound = MIN(self.inputUpperBound, otherLUT.inputUpperBound);

    LUT3D *newLUT = [LUT3D LUTOfSize:outputSize inputLowerBound:usedInputLowerBound inputUpperBound:usedInputUpperBound];
    [newLUT copyMetaPropertiesFromLUT:self];

    [newLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        LUTColor *startColor = [self colorAtColor:[newLUT identityColorAtR:r g:g b:b]];
        LUTColor *lerpLUTColor = [otherLUT colorAtColor:[self identityColorAtR:r g:g b:b]];

        LUTColor *lerpedColor = [startColor lerpTo:lerpLUTColor amount:lerpAmount];

        [newLUT setColor:lerpedColor r:r g:g b:b];
    }];

    return newLUT;
}

- (LUT *)LUTByMixingWithLUT:(LUT *)otherLUT
                  mixAmount:(double)mixAmount{
    NSUInteger outputSize = MAX(clampUpperBound(MAX(self.size, otherLUT.size), COCOALUT_SUGGESTED_MAX_LUT3D_SIZE), self.size);
    double usedInputLowerBound = MAX(self.inputLowerBound, otherLUT.inputLowerBound);
    double usedInputUpperBound = MIN(self.inputUpperBound, otherLUT.inputUpperBound);

    LUT3D *newLUT = [LUT3D LUTOfSize:outputSize inputLowerBound:usedInputLowerBound inputUpperBound:usedInputUpperBound];
    [newLUT copyMetaPropertiesFromLUT:self];

    [newLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        LUTColor *startColor = [self colorAtColor:[newLUT identityColorAtR:r g:g b:b]];
        LUTColor *mixLUTColor = [otherLUT colorAtColor:startColor];

        LUTColor *lerpedColor = [startColor lerpTo:mixLUTColor amount:mixAmount];

        [newLUT setColor:lerpedColor r:r g:g b:b];
    }];
    
    return newLUT;
}

- (instancetype)LUT3DByExtractingColorShiftContrastReferredWithReverseStrictnessType:(LUT1DReverseStrictnessType)strictnessType{
    LUT1D *selfLUT1D = [self LUT1D];

    if([selfLUT1D isReversibleWithStrictnessType:strictnessType] == NO){
        return nil;
    }

    LUT1D *reversed1D = [[selfLUT1D LUTByResizingToSize:2048] LUT1DByReversingWithStrictnessType:strictnessType autoAdjustInputBounds:YES];

    if(reversed1D == nil){
        return nil;
    }
    //reversed1D = [reversed1D LUTByChangingInputLowerBound:self.inputLowerBound inputUpperBound:self.inputUpperBound]; //convenience

    LUT3D *extractedLUT = (LUT3D *)[reversed1D LUTByCombiningWithLUT:self];

    [extractedLUT copyMetaPropertiesFromLUT:self];
    
    if (extractedLUT.size != self.size) {
        extractedLUT = [extractedLUT LUTByResizingToSize:self.size];
    }

    return extractedLUT;
}

- (instancetype)LUT3DByExtractingColorShiftWithReverseStrictnessType:(LUT1DReverseStrictnessType)strictnessType{
    LUT1D *selfLUT1D = [self LUT1D];

    if([selfLUT1D isReversibleWithStrictnessType:strictnessType] == NO){
        return nil;
    }

    LUT1D *reversed1D = [[selfLUT1D LUTByResizingToSize:2048] LUT1DByReversingWithStrictnessType:strictnessType autoAdjustInputBounds:YES];

    if(reversed1D == nil){
        return nil;
    }

    LUT3D *extractedLUT = (LUT3D *)[self LUTByCombiningWithLUT:reversed1D];
    [extractedLUT copyMetaPropertiesFromLUT:self];
    
    if (extractedLUT.size != self.size) {
        extractedLUT = [extractedLUT LUTByResizingToSize:self.size];
    }

    return extractedLUT;
}

- (instancetype)LUT3DByExtractingContrastOnly{
    return [[self LUT1D] LUT3DOfSize:[self size]];
}

- (LUT1D *)LUT1D{
    LUT1D *lut1D = [LUT1D LUTOfSize:[self size] inputLowerBound:[self inputLowerBound] inputUpperBound:[self inputUpperBound]];
    [lut1D copyMetaPropertiesFromLUT:self];

    [lut1D LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        LUTColor *color = [self colorAtR:r g:g b:b];
        [lut1D setColor:color r:r g:g b:b];
    }];

    return lut1D;
}

- (instancetype)LUT3DBySwizzling1DChannelsWithMethod:(LUT1DSwizzleChannelsMethod)method
                                        strictnessType:(LUT1DReverseStrictnessType)strictnessType{
    if(![[self LUT1D] isReversibleWithStrictnessType:strictnessType]){
        return nil;
    }
    LUT3D *extractedColorLUT = [self LUT3DByExtractingColorShiftWithReverseStrictnessType:strictnessType];
    LUT1D *contrastLUT = [[self LUT1D] LUT1DBySwizzling1DChannelsWithMethod:method];
    LUT3D *newLUT = (LUT3D *)[extractedColorLUT LUTByCombiningWithLUT:contrastLUT];
    [newLUT copyMetaPropertiesFromLUT:self];
    return newLUT;
}

- (instancetype)LUT3DByConvertingToMonoWithConversionMethod:(LUTMonoConversionMethod)conversionMethod{
    LUT3D *newLUT = [LUT3D LUTOfSize:[self size] inputLowerBound:[self inputLowerBound] inputUpperBound:[self inputUpperBound]];
    [newLUT copyMetaPropertiesFromLUT:self];

    typedef LUTColor* (^converter)(LUTColor *);

    converter convertToMonoBlock;

    if(conversionMethod == LUTMonoConversionMethodAverageRGB){
        convertToMonoBlock = ^(LUTColor *color){double average = (color.red+color.green+color.blue)/3.0; return [LUTColor colorWithRed:average green:average blue:average];};
    }
    else if (conversionMethod == LUTMonoConversionMethodRec709WeightedRGB){
        convertToMonoBlock = ^(LUTColor *color){return [color colorByChangingSaturation:0 usingLumaR:0.2126 lumaG:0.7152 lumaB:0.0722];};
    }
    else if (conversionMethod == LUTMonoConversionMethodRedCopiedToRGB){
        convertToMonoBlock = ^(LUTColor *color){return [LUTColor colorWithRed:color.red green:color.red blue:color.red];};
    }
    else if (conversionMethod == LUTMonoConversionMethodGreenCopiedToRGB){
        convertToMonoBlock = ^(LUTColor *color){return [LUTColor colorWithRed:color.green green:color.green blue:color.green];};
    }
    else if (conversionMethod == LUTMonoConversionMethodBlueCopiedToRGB){
        convertToMonoBlock = ^(LUTColor *color){return [LUTColor colorWithRed:color.blue green:color.blue blue:color.blue];};
    }
    


    [newLUT LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
        [newLUT setColor:convertToMonoBlock([self colorAtR:r g:g b:b])
                       r:r
                       g:g
                       b:b];
    }];

    return newLUT;

}

+ (M13OrderedDictionary *)LUTMonoConversionMethods{
    return M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"Averaged RGB":@(LUTMonoConversionMethodAverageRGB)},
                                                                  @{@"Rec. 709 Weighted RGB":@(LUTMonoConversionMethodRec709WeightedRGB)},
                                                                  @{@"Copy Red Channel":@(LUTMonoConversionMethodRedCopiedToRGB)},
                                                                  @{@"Copy Green Channel":@(LUTMonoConversionMethodGreenCopiedToRGB)},
                                                                  @{@"Copy Blue Channel":@(LUTMonoConversionMethodBlueCopiedToRGB)}]);
}





+ (NSMutableArray *)blankLatticeArrayOfSize:(NSUInteger)size {
    NSMutableArray *blankArray = [NSMutableArray arrayWithCapacity:size];
    for (int i = 0; i < size; i++) {
        blankArray[i] = [NSNull null];
    }

    NSMutableArray *rArray = [blankArray mutableCopy];
    for (int i = 0; i < size; i++) {
        NSMutableArray *gArray = [blankArray mutableCopy];
        for (int j = 0; j < size; j++) {
            gArray[j] = [blankArray mutableCopy]; // bArray
        }
        rArray[i] = gArray;
    }

    return rArray;
}

- (void)setColor:(LUTColor *)color r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b {
    _latticeArray[r][g][b] = color;
}

- (LUTColor *)colorAtR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b {
    LUTColor *color = _latticeArray[r][g][b];
    if ([color isEqual:[NSNull null]]) {
        return nil;
    }
    return color;
}

- (NSMutableArray *)latticeArrayCopy{
    return [[self latticeArray] mutableCopy];
}

- (BOOL)is1DLUT{
    //resize down to speed up check - shouldn't affect accuracy
    return [[self LUTByResizingToSize:MIN(self.size, 17)] equalsLUT:[[self LUT1D] LUT3DOfSize:MIN(self.size, 17)]];
}

- (bool)equalsLUT:(LUT *)comparisonLUT{
    if(isLUT1D(comparisonLUT)){
        return NO;
    }
    else{
        //it's LUT3D
        if([self size] != [comparisonLUT size]){
            return NO;
        }
        else{
            return [[self latticeArray] isEqualToArray:[(LUT3D *)comparisonLUT latticeArray]];
        }
    }
}


//- (LUTColor *)colorAtInterpolatedR:(double)redPoint g:(double)greenPoint b:(double)bluePoint {
//    if ((redPoint < 0   || redPoint     > self.size - 1) ||
//        (greenPoint < 0 || greenPoint   > self.size - 1) ||
//        (bluePoint < 0  || bluePoint    > self.size - 1)) {
//        @throw [NSException exceptionWithName:@"InvalidInputs"
//                                       reason:[NSString stringWithFormat:@"Tried to access out-of-bounds lattice point r:%f g:%f b:%f", redPoint, greenPoint, bluePoint]
//                                     userInfo:nil];
//    }
//
//    double lowerRedPoint = floor(redPoint);
//    double upperRedPoint = ceil(redPoint);
//    
//    double lowerGreenPoint = floor(greenPoint);
//    double upperGreenPoint = ceil(greenPoint);
//    
//    double lowerBluePoint = floor(bluePoint);
//    double upperBluePoint = ceil(bluePoint);
//
//    LUTColor *C000 = [self colorAtR:lowerRedPoint g:lowerGreenPoint b:lowerBluePoint];
//    LUTColor *C010 = [self colorAtR:lowerRedPoint g:lowerGreenPoint b:upperBluePoint];
//    LUTColor *C100 = [self colorAtR:upperRedPoint g:lowerGreenPoint b:lowerBluePoint];
//    LUTColor *C001 = [self colorAtR:lowerRedPoint g:upperGreenPoint b:lowerBluePoint];
//    LUTColor *C110 = [self colorAtR:upperRedPoint g:lowerGreenPoint b:upperBluePoint];
//    LUTColor *C111 = [self colorAtR:upperRedPoint g:upperGreenPoint b:upperBluePoint];
//    LUTColor *C101 = [self colorAtR:upperRedPoint g:upperGreenPoint b:lowerBluePoint];
//    LUTColor *C011 = [self colorAtR:lowerRedPoint g:upperGreenPoint b:upperBluePoint];
//
//    LUTColor *C00  = [C000 lerpTo:C100 amount:1.0 - (upperRedPoint - redPoint)];
//    LUTColor *C10  = [C010 lerpTo:C110 amount:1.0 - (upperRedPoint - redPoint)];
//    LUTColor *C01  = [C001 lerpTo:C101 amount:1.0 - (upperRedPoint - redPoint)];
//    LUTColor *C11  = [C011 lerpTo:C111 amount:1.0 - (upperRedPoint - redPoint)];
//
//    LUTColor *C1 = [C01 lerpTo:C11 amount:1.0 - (upperBluePoint - bluePoint)];
//    LUTColor *C0 = [C00 lerpTo:C10 amount:1.0 - (upperBluePoint - bluePoint)];
//
//    LUTColor *final = [C0 lerpTo:C1 amount:1.0 - (upperGreenPoint - greenPoint)];
//    
//    
//    return final;
//}

- (LUTColor *)colorAtInterpolatedR:(double)redPoint g:(double)greenPoint b:(double)bluePoint {
    if ((redPoint < 0   || redPoint     > self.size - 1) ||
        (greenPoint < 0 || greenPoint   > self.size - 1) ||
        (bluePoint < 0  || bluePoint    > self.size - 1)) {
        @throw [NSException exceptionWithName:@"InvalidInputs"
                                       reason:[NSString stringWithFormat:@"Tried to access out-of-bounds lattice point r:%f g:%f b:%f", redPoint, greenPoint, bluePoint]
                                     userInfo:nil];
    }
    
    double lowerRedPoint = floor(redPoint);
    double upperRedPoint = ceil(redPoint);
    
    double lowerGreenPoint = floor(greenPoint);
    double upperGreenPoint = ceil(greenPoint);
    
    double lowerBluePoint = floor(bluePoint);
    double upperBluePoint = ceil(bluePoint);
    
    double deltaX = redPoint - lowerRedPoint;
    double deltaY = greenPoint - lowerGreenPoint;
    double deltaZ = bluePoint - lowerBluePoint;
    
    LUTColor *P000 = [self colorAtR:lowerRedPoint g:lowerGreenPoint b:lowerBluePoint];
    LUTColor *P001 = [self colorAtR:lowerRedPoint g:lowerGreenPoint b:upperBluePoint];
    LUTColor *P100 = [self colorAtR:upperRedPoint g:lowerGreenPoint b:lowerBluePoint];
    LUTColor *P010 = [self colorAtR:lowerRedPoint g:upperGreenPoint b:lowerBluePoint];
    LUTColor *P101 = [self colorAtR:upperRedPoint g:lowerGreenPoint b:upperBluePoint];
    LUTColor *P111 = [self colorAtR:upperRedPoint g:upperGreenPoint b:upperBluePoint];
    LUTColor *P110 = [self colorAtR:upperRedPoint g:upperGreenPoint b:lowerBluePoint];
    LUTColor *P011 = [self colorAtR:lowerRedPoint g:upperGreenPoint b:upperBluePoint];
    
    double QTDotB[8];
    
    if (deltaX > deltaY) {
        if (deltaY > deltaZ) {
            QTDotB[0] = 1.0 - deltaX;
            QTDotB[1] = 0;
            QTDotB[2] = 0;
            QTDotB[3] = 0;
            QTDotB[4] = deltaX - deltaY;
            QTDotB[5] = 0;
            QTDotB[6] = deltaY - deltaZ;
            QTDotB[7] = deltaZ;
        }
        else if (deltaX > deltaZ){
            QTDotB[0] = 1.0 - deltaX;
            QTDotB[1] = 0;
            QTDotB[2] = 0;
            QTDotB[3] = 0;
            QTDotB[4] = deltaX - deltaZ;
            QTDotB[5] = deltaZ - deltaY;
            QTDotB[6] = 0;
            QTDotB[7] = deltaY;
        }
        else{
            QTDotB[0] = 1.0 - deltaZ;
            QTDotB[1] = deltaZ - deltaX;
            QTDotB[2] = 0;
            QTDotB[3] = 0;
            QTDotB[4] = 0;
            QTDotB[5] = deltaX - deltaY;
            QTDotB[6] = 0;
            QTDotB[7] = deltaY;
        }
    }
    else{
        if (deltaZ > deltaY) {
            QTDotB[0] = 1.0 - deltaZ;
            QTDotB[1] = deltaZ - deltaY;
            QTDotB[2] = 0;
            QTDotB[3] = deltaY - deltaX;
            QTDotB[4] = 0;
            QTDotB[5] = 0;
            QTDotB[6] = 0;
            QTDotB[7] = deltaX;
        }
        else if(deltaZ > deltaX){
            QTDotB[0] = 1.0 - deltaY;
            QTDotB[1] = 0;
            QTDotB[2] = deltaY - deltaZ;
            QTDotB[3] = deltaZ - deltaX;
            QTDotB[4] = 0;
            QTDotB[5] = 0;
            QTDotB[6] = 0;
            QTDotB[7] = deltaX;
        }
        else{
            QTDotB[0] = 1.0 - deltaY;
            QTDotB[1] = 0;
            QTDotB[2] = deltaY - deltaX;
            QTDotB[3] = 0;
            QTDotB[4] = 0;
            QTDotB[5] = 0;
            QTDotB[6] = deltaX - deltaZ;
            QTDotB[7] = deltaZ;
        }
    }
    
    double red = QTDotB[0]*P000.red + QTDotB[1]*P001.red + QTDotB[2]*P010.red + QTDotB[3]*P011.red + QTDotB[4]*P100.red + QTDotB[5]*P101.red + QTDotB[6]*P110.red + QTDotB[7]*P111.red;
    
    double green = QTDotB[0]*P000.green + QTDotB[1]*P001.green + QTDotB[2]*P010.green + QTDotB[3]*P011.green + QTDotB[4]*P100.green + QTDotB[5]*P101.green + QTDotB[6]*P110.green + QTDotB[7]*P111.green;
    
    double blue = QTDotB[0]*P000.blue + QTDotB[1]*P001.blue + QTDotB[2]*P010.blue + QTDotB[3]*P011.blue + QTDotB[4]*P100.blue + QTDotB[5]*P101.blue + QTDotB[6]*P110.blue + QTDotB[7]*P111.blue;
    
    
    LUTColor *tetraFinal = [LUTColor colorWithRed:red green:green blue:blue];
    
    return tetraFinal;
}

- (NSData *)bitmapDataWithType:(LUTDataType)lutDataType{
    if (lutDataType == LUTDataTypeRGBAf) {
        size_t size = self.size;
        size_t cubeDataSize = size * size * size * sizeof (float) * 4;
        float *cubeData = (float *) malloc (cubeDataSize);

        [self LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
            LUTColor *transformedColor = [self colorAtR:r g:g b:b];

            size_t offset = 4*(b*size*size + g*size + r);

            cubeData[offset]   = (float)transformedColor.red;
            cubeData[offset+1] = (float)transformedColor.green;
            cubeData[offset+2] = (float)transformedColor.blue;
            cubeData[offset+3] = 1.0f;
        }];

        return [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    }
    else if(lutDataType == LUTDataTypeRGBd){
        size_t size = self.size;
        size_t cubeDataSize = size * size * size * sizeof (double) * 3;
        double *cubeData = (double *) malloc (cubeDataSize);

        [self LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
            LUTColor *transformedColor = [self colorAtR:r g:g b:b];

            size_t offset = 3*(b*size*size + g*size + r);

            cubeData[offset]   = (double)transformedColor.red;
            cubeData[offset+1] = (double)transformedColor.green;
            cubeData[offset+2] = (double)transformedColor.blue;
        }];

        return [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    }
    else if(lutDataType == LUTDataTypeRGBf){
        size_t size = self.size;
        size_t cubeDataSize = size * size * size * sizeof (float) * 3;
        float *cubeData = (float *) malloc (cubeDataSize);

        [self LUTLoopWithBlock:^(size_t r, size_t g, size_t b) {
            LUTColor *transformedColor = [self colorAtR:r g:g b:b];

            size_t offset = 3*(b*size*size + g*size + r);

            cubeData[offset]   = (float)transformedColor.red;
            cubeData[offset+1] = (float)transformedColor.green;
            cubeData[offset+2] = (float)transformedColor.blue;
        }];

        return [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    }
    else{
        return nil;
    }
}

- (CIFilter *)coreImageFilterWithColorSpace:(CGColorSpaceRef)colorSpace {
    NSUInteger sizeOfColorCubeFilter = clamp(self.size, 0, COCOALUT_MAX_CICOLORCUBE_SIZE);
    LUT3D *usedLUT = self.size==sizeOfColorCubeFilter?self:[self LUTByResizingToSize:sizeOfColorCubeFilter];

    if (self.inputLowerBound != 0 || self.inputUpperBound != 1) {
        NSLog(@"CocoaLUT: You should only be seeing this message if you are applying a CI LUT filter to a normalized scene-linear image - make sure to change the input bounds to 0-1 if you aren't using normalized scene-linear data.");
    }

    NSData *cubeData = [usedLUT bitmapDataWithType:LUTDataTypeRGBAf];

    CIFilter *colorCube;
    if (colorSpace) {
        colorCube = [CIFilter filterWithName:@"CIColorCubeWithColorSpace"];
        [colorCube setValue:(__bridge id)(colorSpace) forKey:@"inputColorSpace"];
    }
    else {
        colorCube = [CIFilter filterWithName:@"CIColorCube"];
    }
    [colorCube setValue:@(usedLUT.size) forKey:@"inputCubeDimension"];
    [colorCube setValue:cubeData forKey:@"inputCubeData"];

    return colorCube;
}


- (id)copyWithZone:(NSZone *)zone{
    LUT3D *copiedLUT = [super copyWithZone:zone];
    [copiedLUT setLatticeArray:[[self latticeArray] mutableCopyWithZone:zone]];

    return copiedLUT;
}


@end
