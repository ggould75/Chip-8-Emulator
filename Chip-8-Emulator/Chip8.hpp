//
//  Chip8.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#ifndef Chip8_hpp
#define Chip8_hpp

#include <stdint.h>

class Chip8 {

private:
    const uint16_t programStartAddress = 0x200;
    static const short int memorySize = 4096;

    uint8_t memory[memorySize]{};
    
    uint8_t registersV[16]{};
    uint16_t registerI;
    
    uint16_t programCounter;
    
    uint8_t stack[64]{};
    uint8_t stackIndex;
    
    uint16_t opcode;
    
    uint8_t frameBuffer[64 * 32];
    uint8_t delayTimer = 0;
    uint8_t soundTimer = 0;
    bool pressedKeys[0x10]{}; // 16 keys

public:
    
    bool LoadProgramIntoMemory(const char *filename);
    void processInstruction();
};

#endif /* Chip8_hpp */
