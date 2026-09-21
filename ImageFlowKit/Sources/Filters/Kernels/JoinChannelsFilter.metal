#include <CoreImage/CoreImage.h>
#include <metal_stdlib>

extern "C" {
    namespace coreimage {
        float4 join_rgba(sampler r, sampler g, sampler b, sampler a) {
            float cr = unpremultiply(r.sample(r.coord())).r;
            float cg = unpremultiply(g.sample(g.coord())).g;
            float cb = unpremultiply(b.sample(b.coord())).b;
            float ca = unpremultiply(a.sample(a.coord())).a;
            
            float4 result = float4(cr, cg, cb, ca);
            return premultiply(result);
        }
        
        float4 join_rgb(sampler r, sampler g, sampler b) {
            float cr = unpremultiply(r.sample(r.coord())).r;
            float cg = unpremultiply(g.sample(g.coord())).g;
            float cb = unpremultiply(b.sample(b.coord())).b;
            
            float4 result = float4(cr, cg, cb, 1.0);
            return premultiply(result);
        }
    }
}
