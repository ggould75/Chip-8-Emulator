//
//  CEChip8Bridge.mm
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Chip_8_Emulator-Swift.h"
#import "CEChip8Bridge.h"
#import "Chip8.hpp"

void redrawScreen(uint8_t *frameBuffer)
{
    // TODO: get instance of CEChip8Bridge (initialized from VC) and call screenRenderer.draw()
}

@interface CEChip8Bridge () {
    Chip8 *chip8;
}

@property (nonatomic, strong) id<CERenderer> screenRenderer;

@end

@implementation CEChip8Bridge

- (instancetype)initWithScreenRenderer:(id<CERenderer>)renderer
{
    if (self = [super init]) {
        chip8 = new Chip8;
        self.screenRenderer = renderer;
    }
    
    return self;
}

- (void)reset
{
    chip8->Reset();
}

- (void)loadRomWithName:(NSString *)name
{
    NSString *romFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"c8"];
    const char *romFileCString = [romFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    chip8->LoadProgramIntoMemory(romFileCString);
}

- (void)redrawScreen
{
    [self.screenRenderer draw];
}

@end
