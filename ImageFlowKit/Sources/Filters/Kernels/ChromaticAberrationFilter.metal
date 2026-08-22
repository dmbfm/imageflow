#include <CoreImage/CoreImage.h>
#include <metal_stdlib>

extern "C" {
    namespace coreimage {
        float4 ca_kernel(sampler s, float cx, float cy, float intensity, destination dest) {
            
            float2 p = s.coord();
            
            float2 t = p - s.transform(float2(cx, cy));

            float factor = intensity * 0.03;
            
            float b = s.sample(p + float2(0.0, 0.0)).b;
            float g = s.sample(p + float2(-t.x * factor, -t.y * factor)).g;
            float r = s.sample(p + float2(-t.x * factor * 2.0, -t.y * factor * 2.0)).r;
            float a = s.sample(p + float2(0.0, 0.0)).a;
            
            return float4(r, g, b, a);
        }
    }
}
