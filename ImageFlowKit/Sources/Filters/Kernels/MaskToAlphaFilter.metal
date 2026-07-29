
#include <CoreImage/CoreImage.h>
#include <metal_stdlib>

extern "C" {
    namespace coreimage {
        
        float4 alpha_mask_to_alpha(sampler s, sampler m) {
            float4 src_color = unpremultiply(s.sample(s.coord()));
            float4 mask_color = unpremultiply(m.sample(s.coord()));
            
            float4 result = float4(src_color.rgb, min(src_color.a, mask_color.a));
            
            return premultiply(result);
        }
        
        float4 red_mask_to_alpha(sampler s, sampler m) {
            float4 src_color = unpremultiply(s.sample(s.coord()));
            float4 mask_color = unpremultiply(m.sample(s.coord()));
            
            float4 result = float4(src_color.rgb, min(src_color.a, mask_color.r));
            
            return premultiply(result);
        }
        
        float4 green_mask_to_alpha(sampler s, sampler m) {
            float4 src_color = unpremultiply(s.sample(s.coord()));
            float4 mask_color = unpremultiply(m.sample(s.coord()));
            
            float4 result = float4(src_color.rgb, min(src_color.a, mask_color.g));
            
            return premultiply(result);
        }
        
        
        float4 blue_mask_to_alpha(sampler s, sampler m) {
            float4 src_color = unpremultiply(s.sample(s.coord()));
            float4 mask_color = unpremultiply(m.sample(s.coord()));
            
            float4 result = float4(src_color.rgb, min(src_color.a, mask_color.b));
            
            return premultiply(result);
        }
        
        float4 white_mask_to_alpha(sampler s, sampler m) {
            float4 src_color = unpremultiply(s.sample(s.coord()));
            float4 mask_color = unpremultiply(m.sample(s.coord()));
            
            float black = (mask_color.r + mask_color.g + mask_color.b) * (1.0 / 3.0);
            
            float4 result = float4(src_color.rgb, min(src_color.a, black));
            
            return premultiply(result);
        }
    }
}
