//
//  CEChip8Bridge.mm
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "CEChip8Bridge.h"
#include "Chip8.hpp"

@interface CEChip8Bridge () {
    Chip8 *chip8;
}

@end

@implementation CEChip8Bridge

- (instancetype)init
{
    if (self = [super init]) {
        chip8 = new Chip8;
    }
    
    return self;
}

- (void)reset
{
    
}

- (void)loadRomWithName:(NSString *)name
{
    NSString *romFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"c8"];
    const char *romFileCString = [romFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    chip8->LoadProgramIntoMemory(romFileCString);
}

@end
