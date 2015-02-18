//
//  LUTFormatterDiscreet1DLUT.m
//  Pods
//
//  Created by Greg Cotten on 3/5/14.
//
//

#import "LUTFormatterDiscreet1DLUT.h"

@implementation LUTFormatterDiscreet1DLUT

+ (void)load{
    [super load];
}

+ (LUT *)LUTFromLines:(NSArray *)lines {

    NSString *description;
    NSMutableDictionary *metadata;
    NSMutableDictionary *passthroughFileOptions = [NSMutableDictionary dictionary];

    passthroughFileOptions[@"fileTypeVariant"] = @"Discreet";


    NSMutableArray *trimmedLines = [NSMutableArray array];
    int integerMaxOutput = -1;
    int lutSize = -1;
    NSUInteger lutLinesStartIndex = findFirstLUTLineInLinesWithWhitespaceSeparators(lines, 1, 0);

    if(lutLinesStartIndex == -1){
        @throw [NSException exceptionWithName:@"Discreet1DParserError" reason:@"Couldn't find start of LUT data lines." userInfo:nil];
    }

    NSArray *headerLines = [lines subarrayWithRange:NSMakeRange(0, lutLinesStartIndex)];

    NSDictionary *metadataAndDescription = [LUTMetadataFormatter metadataAndDescriptionFromLines:headerLines];
    metadata = metadataAndDescription[@"metadata"];
    description = metadataAndDescription[@"description"];

    NSInteger lutChannels = 0;

    //trim for lut values only and grab the max code value
    for (NSString *line in lines) {
        NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedLine.length > 0 && [trimmedLine rangeOfString:@"#"].location == NSNotFound && [trimmedLine rangeOfString:@"LUT"].location == NSNotFound){
            [trimmedLines addObject:trimmedLine];
        }
        if([trimmedLine rangeOfString:@"Scale"].location != NSNotFound){
            integerMaxOutput = [[trimmedLine componentsSeparatedByString:@":"][1] intValue];
            passthroughFileOptions[@"fileTypeVariant"] = @"Nuke";
        }
        if([trimmedLine rangeOfString:@"LUT"].location != NSNotFound){
            NSArray *components = [trimmedLine componentsSeparatedByString:@" "];
            lutSize = [components[2] intValue];
            lutChannels = [components[1] intValue];

            if ([passthroughFileOptions[@"fileTypeVariant"] isEqualToString:@"Discreet"]) {
                if (components.count >= 4) {
                    integerMaxOutput = [components[3] intValue] - 1;
                }
                else{
                    integerMaxOutput = lutSize-1;
                }

            }
        }
    }

    if ([passthroughFileOptions[@"fileTypeVariant"] isEqualToString:@"Discreet"]){
        passthroughFileOptions[@"lutSize"] = @(lutSize);
    }

    passthroughFileOptions[@"integerMaxOutput"] = @(integerMaxOutput);

    passthroughFileOptions[@"lutChannels"] = @(lutChannels);

    if (lutChannels != 1 && lutChannels != 3) {
        @throw [NSException exceptionWithName:@"Discreet1DParserError" reason:@"Invalid LUT channels (1 or 3 only)." userInfo:nil];
    }

    if(lutChannels == 3 && trimmedLines.count < lutSize*3){
        @throw [NSException exceptionWithName:@"Discreet1DParserError" reason:@"Incomplete data lines." userInfo:nil];
    }
    if(lutChannels == 1 && trimmedLines.count < lutSize){
        @throw [NSException exceptionWithName:@"Discreet1DParserError" reason:@"Incomplete data lines." userInfo:nil];
    }

    for(NSString *checkLine in trimmedLines){
        if(stringIsValidNumber(checkLine) == NO){
            @throw [NSException exceptionWithName:@"Discreet1DParserError" reason:[NSString stringWithFormat:@"NaN detected in LUT: \"%@\"", checkLine] userInfo:nil];
        }
    }

    LUT1D *lut;

    if (lutChannels == 3) {
        NSMutableArray *redCurve = [NSMutableArray array];
        NSMutableArray *greenCurve = [NSMutableArray array];
        NSMutableArray *blueCurve = [NSMutableArray array];

        //get red values
        for (int i = 0; i < lutSize; i++) {
            [redCurve addObject:@(nsremapint01([trimmedLines[i] integerValue], integerMaxOutput))];
        }
        //get green values
        for (int i = lutSize; i < 2*lutSize; i++) {
            [greenCurve addObject:@(nsremapint01([trimmedLines[i] integerValue], integerMaxOutput))];
        }
        //get blue values
        for (int i = 2*lutSize; i < 3*lutSize; i++) {
            [blueCurve addObject:@(nsremapint01([trimmedLines[i] integerValue], integerMaxOutput))];
        }

        lut = [LUT1D LUT1DWithRedCurve:redCurve greenCurve:greenCurve blueCurve:blueCurve lowerBound:0.0 upperBound:1.0];
    }
    else if(lutChannels == 1){
        //get mono values
        NSMutableArray *monoCurve = [NSMutableArray array];

        for (int i = 0; i < lutSize; i++) {
            [monoCurve addObject:@(nsremapint01([trimmedLines[i] integerValue], integerMaxOutput))];
        }

        lut = [LUT1D LUT1DWith1DCurve:monoCurve lowerBound:0 upperBound:1];
    }

    [lut setMetadata:metadata];
    lut.descriptionText = description;
    [lut setPassthroughFileOptions:@{[self formatterID]: passthroughFileOptions}];
    return lut;
}

+ (NSString *)stringFromLUT:(LUT *)lut withOptions:(NSDictionary *)options {

    if(![self optionsAreValid:options]){
        @throw [NSException exceptionWithName:@"Discreet1DWriterError" reason:[NSString stringWithFormat:@"Options don't pass the spec: %@", options] userInfo:nil];
    }
    else{
        options = options[[self formatterID]];
    }

    NSMutableString *string = [NSMutableString stringWithString:@""];

    NSUInteger integerMaxOutput  = [options[@"integerMaxOutput"] integerValue];
    NSUInteger lutChannels  = [options[@"lutChannels"] integerValue];

    LUT1D *lut1D = LUTAsLUT1D(lut, [lut size]);
    if ([options[@"fileTypeVariant"] isEqualToString:@"Nuke"]) {
        [string appendString:[NSString stringWithFormat:@"#\n# Discreet LUT file\n#\tChannels: 3\n# Input Samples: %d\n# Ouput Scale: %d\n#\n# Exported from CocoaLUT\n#\nLUT: %i %d\n\n", (int)[lut size], (int)integerMaxOutput, (int)lutChannels, (int)[lut size]]];
    }
    else if([options[@"fileTypeVariant"] isEqualToString:@"Discreet"]){
        if (lut.size != integerMaxOutput+1) {
            [string appendFormat:@"LUT: %i %i %i\n\n", (int)lutChannels, (int)lut.size, (int)integerMaxOutput+1];
        }
        else{
            [string appendFormat:@"LUT: %i %i\n\n", (int)lutChannels, (int)lut.size];
        }

    }

    if (lutChannels == 3) {
        //write red
        for (int i = 0; i < [lut size]; i++) {
            [string appendString:[NSString stringWithFormat:@"%d\n", (int)([lut1D valueAtR:i]*(double)integerMaxOutput) ]];
        }
        //write green
        for (int i = 0; i < [lut size]; i++) {
            [string appendString:[NSString stringWithFormat:@"%d\n", (int)([lut1D valueAtG:i]*(double)integerMaxOutput) ]];
        }
        //write blue
        for (int i = 0; i < [lut size]; i++) {
            [string appendString:[NSString stringWithFormat:@"%d\n", (int)([lut1D valueAtB:i]*(double)integerMaxOutput) ]];
        }
    }
    else if (lutChannels == 1){
        for (int i = 0; i < [lut size]; i++) {
            [string appendString:[NSString stringWithFormat:@"%d\n", (int)([lut1D valueAtR:i]*(double)integerMaxOutput) ]];
        }
    }


    return string;

}

+ (NSArray *)conformanceLUTActionsForLUT:(LUT *)lut options:(NSDictionary *)options{
    NSMutableArray *actions = [NSMutableArray arrayWithArray:[super conformanceLUTActionsForLUT:lut options:options]];

    NSDictionary *exposedOptions = options[[self formatterID]];

    if ([exposedOptions[@"lutChannels"] integerValue] == 1) {
        if (!actions) {
            actions = [[NSMutableArray alloc] init];
        }
        [actions addObject:[LUTAction actionWithLUTBySwizzlingWithMethod:LUT1DSwizzleChannelsMethodAverageRGB]];
    }

    return actions;
}



+ (LUTFormatterOutputType)outputType{
    return LUTFormatterOutputType1D;
}

+ (NSArray *)allOptions{

    NSDictionary *discreetOptions =
    @{@"fileTypeVariant":@"Discreet",
      @"lutSize": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"1024": @(1024)},
                                                                         @{@"4096": @(4096)},
                                                                         @{@"65536": @(65536)}]),
      @"integerMaxOutput": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"10-bit": @(maxIntegerFromBitdepth(10))},
                                                                                  @{@"12-bit": @(maxIntegerFromBitdepth(12))},
                                                                                  @{@"16-bit": @(maxIntegerFromBitdepth(16))}]),
      @"lutChannels": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"RGB": @(3)},
                                                                             @{@"Mono": @(1)}])};

    NSDictionary *nukeOptions =
    @{@"fileTypeVariant":@"Nuke",
      @"integerMaxOutput": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"10-bit": @(maxIntegerFromBitdepth(10))},
                                                                                  @{@"12-bit": @(maxIntegerFromBitdepth(12))},
                                                                                  @{@"16-bit": @(maxIntegerFromBitdepth(16))}]),
      @"lutChannels": M13OrderedDictionaryFromOrderedArrayWithDictionaries(@[@{@"RGB": @(3)},
                                                                             @{@"Mono": @(1)}])};

    return @[discreetOptions, nukeOptions];
}

+ (NSDictionary *)defaultOptions{
    NSDictionary *dictionary = @{@"fileTypeVariant": @"Discreet",
                                 @"integerMaxOutput": @(maxIntegerFromBitdepth(12)),
                                 @"lutSize":@(4096),
                                 @"lutChannels":@(3)};
    return @{[self formatterID]:dictionary};
}

+ (NSString *)utiString{
    return @"com.discreet.lut";
}

+ (NSArray *)fileExtensions{
    return @[@"lut"];
}

+ (NSString *)formatterName{
    return @"Discreet 1D LUT";
}

+ (NSString *)formatterID{
    return @"discreet";
}

+ (BOOL)canRead{
    return YES;
}

+ (BOOL)canWrite{
    return YES;
}


@end
