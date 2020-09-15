//
//  CEChip8Bridge.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(Chip8Bridge)
@interface CEChip8Bridge : NSObject

- (void)reset;
- (void)loadRomWithName:(NSString *)name;

@end
