//
//  Chip8.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#ifndef Chip8_hpp
#define Chip8_hpp

#include <stdio.h>
#include <stdint.h>

class Chip8 {

private:
    const uint16_t programStartAddress = 0x200;
    static const uint16_t memorySize = 4096;
    static const uint8_t stackSize = 64;
    static const uint8_t numberOfRegisters = 16;
    static const uint8_t numberOfKeys = 0x10; // 16 keys
    
    uint8_t memory[memorySize]{};
    
    uint8_t registersV[numberOfRegisters]{};
    uint16_t registerI;
    
    uint16_t programCounter;
    
    // Using 16 bits stack instead of 8 bits, otherwise some values will not be stored properly
    uint16_t stack[stackSize]{};
    uint8_t stackIndex = 0;
    
    uint16_t opcode;
    
    uint8_t frameBuffer[64 * 32];
    uint8_t delayTimer = 0;
    uint8_t soundTimer = 0;
    bool pressedKeys[numberOfKeys]{};

    uint16_t ArgVx(uint16_t opcode) const;
    uint16_t ArgVy(uint16_t opcode) const;
    uint16_t ArgN(uint16_t opcode) const;
    uint16_t ArgNN(uint16_t opcode) const;
    uint16_t ArgNNN(uint16_t opcode) const;
    
public:
    Chip8();
    
    bool LoadProgramIntoMemory(const char *filename);
    void ProcessInstruction();
    void RunLoop();
    void Reset();
};

#endif /* Chip8_hpp */
