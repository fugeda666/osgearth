#pragma vp_entryPoint oe_rex_normalMapVS
#pragma vp_location   vertex_view
#pragma vp_order      0.5

#pragma import_defines(OE_TERRAIN_RENDER_NORMAL_MAP)

uniform mat4 oe_tile_normalTexMatrix;
uniform vec2 oe_tile_elevTexelCoeff;

uniform mat4 oe_tile_elevationTexMatrix;

// stage globals
out vec4 oe_layer_tilec;
out vec2 oe_normal_uv;
out vec3 oe_normal_binormal;

void oe_rex_normalMapVS(inout vec4 unused)
{
#ifndef OE_TERRAIN_RENDER_NORMAL_MAP
    return;
#endif

    // calculate the sampling coordinates for the normal texture
    //oe_normalMapCoords = (oe_tile_normalTexMatrix * oe_layer_tilec).st;

    //oe_normalMapCoords = oe_layer_tilec.st
    //    * oe_tile_elevTexelCoeff.x * oe_tile_normalTexMatrix[0][0]
    //    + oe_tile_elevTexelCoeff.x * oe_tile_normalTexMatrix[3].st
    //    + oe_tile_elevTexelCoeff.y;

    oe_normal_uv = oe_layer_tilec.st
        * oe_tile_elevTexelCoeff.x * oe_tile_elevationTexMatrix[0][0]
        + oe_tile_elevTexelCoeff.x * oe_tile_elevationTexMatrix[3].st
        + oe_tile_elevTexelCoeff.y;

    // send the bi-normal to the fragment shader
    oe_normal_binormal = normalize(gl_NormalMatrix * vec3(0, 1, 0));
}


[break]

#pragma vp_entryPoint oe_rex_normalMapFS
#pragma vp_location   fragment_coloring
#pragma vp_order      0.1

#pragma import_defines(OE_TERRAIN_RENDER_NORMAL_MAP)

// import terrain SDK
vec4 oe_terrain_getNormalAndCurvature(in vec2);

uniform sampler2D oe_tile_normalTex;

in vec3 vp_Normal;
in vec3 oe_UpVectorView;
in vec2 oe_normal_uv;
in vec3 oe_normal_binormal;

// global
mat3 oe_normalMapTBN;

void oe_rex_normalMapFS(inout vec4 color)
{
#ifndef OE_TERRAIN_RENDER_NORMAL_MAP
    return;
#endif

    vec4 N = oe_terrain_getNormalAndCurvature(oe_normal_uv);

    vec3 tangent = normalize(cross(oe_normal_binormal, oe_UpVectorView));
    oe_normalMapTBN = mat3(tangent, oe_normal_binormal, oe_UpVectorView);
    vp_Normal = normalize(oe_normalMapTBN*N.xyz);
}