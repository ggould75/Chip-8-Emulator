//
//  Chip8.cpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include "Chip8.hpp"

#include <string.h> // FIXME: for memset
#include <stdio.h>

bool Chip8::LoadProgramIntoMemory(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == nullptr) {
        return false;
    }

    size_t result = fread(memory + programStartAddress, 1, memorySize - programStartAddress, file);
    if (result == 0 || ferror(file))
    {
        fclose(file);
        return false;
    }

    fclose(file);

    return true;
}

void Chip8::processInstruction() {
    // Fetch instruction
    opcode = memory[programCounter] << 8 & memory[programCounter + 1];
    
    switch (opcode & 0xF000) {
        // 0nnn - SYS addr. Ignored, not implemented in modern interpreters.
        
        case 0x0000:
            switch (opcode & 0x00FF) {
                // 00E0 - CLS
                case 0x00E0:
                    memset(&frameBuffer, 64 * 32, sizeof(uint8_t));
                    programCounter += 2;
                    break;
                
                // 00EE - RET
                case 0x00EE:
                    stackIndex--;
                    programCounter = stack[stackIndex];
                    programCounter += 2;
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1nnn - JP addr
        case 0x1000:
            programCounter = opcode & 0x0FFF;
            break;
            
        // 2nnn - CALL addr
        case 0x2000:
            stack[stackIndex] = programCounter;
            stackIndex++;
            programCounter = opcode & 0x0FFF;
            break;
           
        // 3xkk - SE Vx, byte
        case 0x3000: {
            uint8_t registerIndex = (opcode & 0x0F00) >> 8;
            uint8_t registerValue = registersV[registerIndex];
            
            if (registerValue == (opcode & 0x00FF)) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 4xkk - SNE Vx, byte
        case 0x4000: {
            uint8_t registerIndex = (opcode & 0x0F00) >> 8;
            uint8_t registerValue = registersV[registerIndex];
            
            if (registerValue != (opcode & 0x00FF)) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 5xy0 - SE Vx, Vy
        case 0x5000: {
            uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
            uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
            uint8_t registerVxValue = registersV[registerVxIndex];
            uint8_t registerVyValue = registersV[registerVyIndex];
            
            if (registerVxValue == registerVyValue) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 6xkk - LD Vx, byte
        case 0x6000: {
            uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
            registersV[registerVxIndex] = opcode & 0x00FF;
            programCounter += 2;
            break;
        }
        
        // 7xkk - ADD Vx, byte
        case 0x7000: {
            uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
            registersV[registerVxIndex] += opcode & 0x00FF;
            programCounter += 2;
            break;
        }
           
        case 0x8000:
            switch (opcode & 0x000F) {
                // 8xy0 - LD Vx, Vy
                case 0x0000: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    registersV[registerVxIndex] = registersV[registerVyIndex];
                    programCounter += 2;
                    break;
                }
                    
                // 8xy1 -  OR Vx, Vy
                case 0x0001: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    registersV[registerVxIndex] |= registersV[registerVyIndex];
                    programCounter += 2;
                    break;
                }
                
                // 8xy2 -  AND Vx, Vy
                case 0x0002: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    registersV[registerVxIndex] &= registersV[registerVyIndex];
                    programCounter += 2;
                    break;
                }
                
                // 8xy3 -  XOR Vx, Vy
                case 0x0003: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    registersV[registerVxIndex] ^= registersV[registerVyIndex];
                    programCounter += 2;
                    break;
                }
                 
                // 8xy4 -  ADD Vx, Vy
                case 0x0004: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    uint16_t result = (uint16_t)registersV[registerVxIndex] + (uint16_t)registersV[registerVyIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0x100;
                    programCounter += 2;
                    break;
                }
                    
                // 8xy5 - SUB Vx, Vy
                case 0x0005: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    uint16_t result = (uint16_t)registersV[registerVxIndex] - (uint16_t)registersV[registerVyIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0;
                    programCounter += 2;
                    break;
                }
                
                // 8xy6 - SHR Vx {, Vy}
                case 0x0006: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    registersV[0xF] = registersV[registerVxIndex] & 0x1;
                    registersV[registerVxIndex] >>= 1;
                    programCounter += 2;
                    break;
                }
                
                // 8xy7 - SUBN Vx, Vy
                case 0x0007: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
                    uint16_t result = (uint16_t)registersV[registerVyIndex] - (uint16_t)registersV[registerVxIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0;
                    programCounter += 2;
                    break;
                }
                    
                // 8xyE - SHL Vx {, Vy}
                case 0x0008: {
                    uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
                    registersV[0xF] = registersV[registerVxIndex] & 0x1;
                    registersV[registerVxIndex] <<= 1;
                    programCounter += 2;
                    break;
                }
                    
                default:
                    break;
            }
            break;
           
        // 9xy0 - SNE Vx, Vy
        case 0x9000: {
            uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
            uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
            if (registersV[registerVxIndex] != registersV[registerVyIndex]) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
            
        // LD I, addr
        case 0xA000:
            registerI = opcode & 0x0FFF;
            programCounter += 2;
            break;
        
        // Bnnn - JP V0, addr
        case 0xB000: {
            uint16_t nnn = opcode & 0x0FFF;
            programCounter = nnn + registersV[0];
            break;
        }
            
        // DRW Vx, Vy, height
        case 0xD000:
            uint8_t registerVxIndex = (opcode & 0x0F00) >> 8;
            uint8_t registerVyIndex = (opcode & 0x00F0) >> 4;
            uint8_t x = registersV[registerVxIndex];
            uint8_t y = registersV[registerVyIndex];
            uint8_t spriteHeight = opcode & 0x000F;
            uint8_t pixel;
            
            registersV[0xF] = 0;
            
            for (uint8_t lineY = 0; lineY < spriteHeight; lineY++) {
                uint8_t line = memory[registerI + lineY];
                
                for (uint8_t lineX = 0; lineX < 8; lineX++) {
                    pixel = line & (0x80 >> lineX);
                    uint8_t bufferIndex = x + lineX + (y + lineY) * 64;
                    uint8_t currentPixel = frameBuffer[bufferIndex];
                    frameBuffer[bufferIndex] = currentPixel ^ pixel;
                    if (currentPixel != 0 && frameBuffer[bufferIndex] == 0) {
                        registersV[0xF] = 1;
                    }
                }
            }
            
            programCounter += 2;
            break;
    }
}
