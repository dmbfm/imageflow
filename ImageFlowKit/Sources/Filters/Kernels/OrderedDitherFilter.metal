#include <CoreImage/CoreImage.h>
#include <metal_stdlib>

extern "C" {
    namespace coreimage {
        float triangle_noise(const float2 n) {
            // triangle noise, in [-0.5..1.5[ range
            float2 p = fract(n * float2(5.3987, 5.4421));
            p += dot(p.yx, p.xy + float2(21.5351, 14.3137));
            
            float xy = p.x * p.y;
            // compute in [0..2[ and remap to [-1.0..1.0[
            float noise = (fract(xy * 95.4307) + fract(xy * 75.04961) - 1.0);
            //noise = sign(noise) * (1.0 - sqrt(1.0 - abs(noise)));
            return noise;
        }
        
        float4 ordered_dither(sampler s_im, sampler s_pat, float4 c0, float4 c1, float ox, float oy, float w, float h, float noise_amount, float bias, destination dest) {
            
            float4 c = unpremultiply(s_im.sample(s_im.coord()));
            float4 m = s_pat.sample(s_pat.coord());
            
            float luma = (c.r * 0.2126) + (c.g * 0.7152) + (c.b * 0.0722);
            float noise = triangle_noise(dest.coord());
            luma += noise_amount * 0.5 * noise + bias;
            
            if (luma > m.r) {
                return premultiply(float4(c1.rgb, c1.a * c.a));
            } else {
                return premultiply(float4(c0.rgb, c0.a * c.a));
            }
        }
    }
}
