TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
float4 _CameraColorTexture_TexelSize;

//
// Painterly
//
void Painterly_float(float2 UV, float _Radius, out float3 Out)
{
    Out = 0;

    #ifndef SHADERGRAPH_PREVIEW

    float3 mean[4] = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    };

    float3 sigma[4] = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    };

    float2 start[4] = {{-_Radius, -_Radius}, {-_Radius, 0}, {0, -_Radius}, {0, 0}};

    float2 pos;
    float3 col;
    for (int k = 0; k < 4; k++) {
        for(int i = 0; i <= _Radius; i++) {
            for(int j = 0; j <= _Radius; j++) {
                pos = float2(i, j) + start[k];

                col = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, float4(UV + float2(pos.x * _CameraColorTexture_TexelSize.x, pos.y * _CameraColorTexture_TexelSize.y), 0., 0.)).rgb;
                mean[k] += col; 
                sigma[k] += col * col;
            }
        }
    }

    float sigma2;

    float n = pow(_Radius + 1, 2);
    float4 color = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, UV);
    float min = 1;

    for (int l = 0; l < 4; l++) {
        mean[l] /= n;
        sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
        sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;

        if (sigma2 < min) {
            min = sigma2;
            color.rgb = mean[l].rgb;
        }
    }

    Out = color;

    #endif
}