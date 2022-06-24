//
//  FrameBufferTexture.metal
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 12/06/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

struct v2f
{
    float4 position [[position]];
    float2 textureCoordinate;
};

v2f vertex vertexMain( uint vertexId [[vertex_id]],
                       device const ScreenVertex* positions [[buffer(0)]] )
{
    v2f o;
    o.position = float4( positions[ vertexId ].position.xy, 1.0 );
    o.textureCoordinate = positions[ vertexId ].textureCoordinate;
    
    return o;
}

fragment float4
fragmentMainNearest(v2f in [[stage_in]],
                    texture2d<half> colorTexture [[ texture(0) ]])
{
    constexpr sampler textureSampler (mag_filter::nearest,
                                      min_filter::nearest);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);

    return float4(colorSample);
}
