//
//  ObjectiveCppBridge.mm
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "CEObjectiveCppBridge.h"
#include "Chip8.hpp"

@implementation CEObjectiveCppBridge

- (void)testLoadingRom
{
    NSString *resourcePath = [NSBundle mainBundle].resourcePath;
    NSString *romFilePath = [NSString stringWithFormat:@"%@/Roms/tetris.c8", resourcePath];
    const char *romFileCString = [romFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    Chip8 *chip8 = new Chip8;
    chip8->LoadProgramIntoMemory(romFileCString);
}

@end
