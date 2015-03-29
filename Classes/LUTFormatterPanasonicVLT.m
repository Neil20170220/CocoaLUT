//
//  LUTFormatterPanasonicVLT.m
//  Pods
//
//  Created by Greg Cotten on 3/28/15.
//
//

#import "LUTFormatterPanasonicVLT.h"

@implementation LUTFormatterPanasonicVLT

+ (void)load{
    [super load];
}

+ (LUT *)LUTFromLines:(NSArray *)lines{
    LUT3D *lut = [LUT3D LUTOfSize:17 inputLowerBound:0 inputUpperBound:1];
    lines = arrayWithEmptyElementsRemoved(lines);
    NSInteger firstLUTLine = findFirstLUTLineInLinesWithWhitespaceSeparators(lines, 3, 0);
    int currentCubeIndex = 0;

    for (int i = (int)firstLUTLine; i < lines.count; i++) {
        NSArray *components = [lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (components.count != 3) {
            @throw [NSException exceptionWithName:@"PanasonicVLUTParserError" reason:[NSString stringWithFormat:@"Invalid line. (%i:%@)", i+1, lines[i]] userInfo:nil];
        }


        NSUInteger redIndex = currentCubeIndex % 17;
        NSUInteger greenIndex = ( (currentCubeIndex % (17 * 17)) / (17) );
        NSUInteger blueIndex = currentCubeIndex / (17 * 17);

        LUTColor *color = [LUTColor colorWithRed:[components[0] doubleValue]/4095.0 green:[components[1] doubleValue]/4095.0 blue:[components[2] doubleValue]/4095.0];

        [lut setColor:color r:redIndex g:greenIndex b:blueIndex];

        currentCubeIndex++;
    }
    lut.passthroughFileOptions = @{[self formatterID]:@{@"fileTypeVariant":@"v1.0",
                                                        @"lutSize":@17}};
    
    return lut;

}


+ (NSString *)stringFromLUT:(LUT *)lut withOptions:(NSDictionary *)options{
    NSMutableString *output = [[NSMutableString alloc] init];

    [output appendString:@"# panasonic vlt file version 1.0\n# source vlt file \"\"\nLUT_3D_SIZE 17\n\n"];
    NSUInteger lutSize = lut.size;
    NSUInteger arrayLength = lutSize * lutSize * lutSize;
    for (int i = 0; i < arrayLength; i++) {
        int redIndex = i % lutSize;
        int greenIndex = ((i % (lutSize * lutSize)) / (lutSize) );
        int blueIndex = i / (lutSize * lutSize);

        LUTColor *color = [lut colorAtR:redIndex g:greenIndex b:blueIndex];

        [output appendFormat:@"%i %i %i", (int)(color.red*4095), (int)(color.green*4095), (int)(color.blue*4095)];

        if(i != arrayLength - 1) {
            [output appendString:@"\n"];
        }

    }

    return output;
}

+ (NSDictionary *)constantConstraints{
    return @{@"inputBounds":@[@0, @1],
             @"outputBounds":@[@0, @1]};
}

+ (LUTFormatterOutputType)outputType{
    return LUTFormatterOutputType3D;
}

+ (NSArray *)allOptions{
    NSDictionary *options = @{@"fileTypeVariant":@"v1.0",
                              @"lutSize": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"17": @(17)}])};

    return @[options];
}

+ (NSDictionary *)defaultOptions{
    NSDictionary *dictionary = @{@"fileTypeVariant": @"v1.0",
                                 @"lutSize":@(17)};

    return @{[self formatterID]: dictionary};
}

+ (NSString *)formatterName{
    return @"Panasonic VLT 3D LUT";
}

+ (NSString *)formatterID{
    return @"pansonicVLT";
}

+ (BOOL)canRead{
    return YES;
}

+ (BOOL)canWrite{
    return YES;
}

+ (NSString *)utiString{
    return @"net.panasonic.vlt";
}

+ (NSArray *)fileExtensions{
    return @[@"vlt"];
}

@end


