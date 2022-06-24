//
//  ShaderTypes.h
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 12/06/2022.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

struct ScreenVertex
{
    vector_float2 position;
    vector_float2 textureCoordinate;
};

#endif /* ShaderTypes_h */
