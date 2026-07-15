#include <CoreImage/CoreImage.h>
#include <metal_stdlib>

#define INTERP_LINEAR       0
#define INTERP_STEP         1

#define GRAD_TYPE_LINEAR    0
#define GRAD_TYPE_RADIAL    1

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
        
        float4 interp(int type, float p0, float p1, float4 c0, float4 c1, float x) {
            switch (type) {
                case INTERP_LINEAR:
                {
                    float s = (x - p0) / (p1 - p0);
                    return mix(c0, c1, s);
                } break;
                case INTERP_STEP: return c0;
                default: return c0;
            }
        }
        
        float4 grad_sample(sampler data, int interp_type, float s) {
            int num_points = (int)data.size().x;
            
            if (num_points < 2) {
                return float4(0.0, 0.0, 0.0, 0.0);
            }
            
            for (int i = 0; i < (num_points - 1); i++) {
                float u = (int) i;
                float p0 = data.sample(float2(u, 0.0)).x;
                float p1 = data.sample(float2(u + 1.0, 0.0)).x;
                float4 c0 = data.sample(float2(u, 1.0));
                float4 c1 = data.sample(float2(u + 1.0, 1.0));
                
                if ((s < p0) && (i == 0)) {
                    return c0;
                } else if ((s >= p1) && (i == (num_points - 2))) {
                    return c1;
                } else if ((s >= p0) && (s < p1)) {
                    return interp(interp_type, p0, p1, c0, c1, s);
                }
            }
            
            return float4(0.0, 0.0, 0.0, 0.0);
        }
        
        float4 filter_kernel(sampler data, int interp_type, float noise_amount, float2 p0, float2 p1, destination dest) {
            int gradient_type = GRAD_TYPE_LINEAR;
            
            
            switch (gradient_type) {
                case GRAD_TYPE_LINEAR:
                {
                    float p0p1norm = length(p1 - p0);
                    float2 d = normalize(p1 - p0);
                    float s = clamp(dot((dest.coord() - p0), d) / p0p1norm, 0.0, 1.0);
                    
                    if (noise_amount > 0) {
                        s += noise_amount * 0.15 * triangle_noise(dest.coord());
                    }
                    
                    return grad_sample(data, interp_type, s);
                } break;
                    
                case GRAD_TYPE_RADIAL:
                {
                    return float4(1.0, 0.0, 0.0, 1.0);
                } break;
                    
                default:
                    return float4(1.0, 0.0, 0.0, 1.0);
            }
        }
    }
}
