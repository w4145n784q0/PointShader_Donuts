//───────────────────────────────────────
 // テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); //テクスチャー
SamplerState g_sampler : register(s0); //サンプラー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ワールド・ビュー・プロジェクションの合成行列
    float4x4 matW; //ワールドに変換するマトリクス（スケールはかけない）ローカル座標を変換する
    float4x4 matNormal; // ワールド変換用の行列　法線を変換する
    float4 diffuseColor; //マテリアルの色＝拡散反射係数
    float2 factor; //拡散光の反射係数
    float4 ambientColor; //環境光（使わない）
    float4 specularColor; //鏡面反射（使わない）
    float4 shininess; //（使わない）
    bool isTextured; //テクスチャーが貼られているかどうか
};


cbuffer gStage : register(b1)
{
    float4 lightPosition; //光源ベクトル
    float4 eyePosition;
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
    //float4 wpos : POSITION0; //位置(ワールド)
    float4 pos : SV_POSITION; //位置(ローカル)
    float2 uv : TEXCOORD; //UV座標
    float4 color : COLOR; //色（明るさ）
    float4 normal : NORMAL;
   // float4 eyev : POSITION1;
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//ピクセルシェーダーへ渡す情報
    VS_OUT outData;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
    outData.pos = mul(pos, matWVP);
	
	//uvはそのまま
    outData.uv = uv;

	//法線ベクトルにワールド行列をかける
    normal = mul(normal, matNormal);
	
	//光源ベクトルを正規化
    float4 light = lightPosition;
    light = normalize(light);
	
	//光源ベクトルと法線の内積をとって0~1.0でとる
    outData.color = clamp(dot(normal, light), 0, 1);

    //float4 OutColor;
    //if (outData.color < 1.0f / 4)
    //{
    //    OutColor = float4(0 / 3.0f, 0 / 3.0f, 0 / 3.0f, 1.0f);

    //}
    //else if (outData.color < 2.0f / 4)
    //{
    //    OutColor = float4(1 / 3.0f, 1 / 3.0f, 1 / 3.0f, 1.0f);
    //}
    //else if (outData.color < 3.0f / 4)
    //{
    //    OutColor = float4(2 / 3.0f, 2 / 3.0f, 2 / 3.0f, 1.0f);
    //}
    //else
    //{
    //    OutColor = float4(3 / 3.0f, 3 / 3.0f, 3 / 3.0f, 1.0f);
    //}
    //outData.color = OutColor;
	
	//まとめて出力
    return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
    float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 ambentSource = float4(0.2 ,0.2, 0.2, 1.0);
    float4 diffuse;
    float4 ambient;
	
    float4 NL = saturate(dot(inData.normal, normalize(lightPosition)));
    float4 n1 = float4(1 / 4.0, 1 / 4.0, 1 / 4.0, 1.0);
    float4 n2 = float4(2 / 4.0, 2 / 4.0, 2 / 4.0, 1.0);
    float4 n3 = float4(3 / 4.0, 3 / 4.0, 3 / 4.0, 1.0);
    float4 n4 = float4(4 / 4.0, 4 / 4.0, 4 / 4.0, 1.0);
    
    float4 tI = 0.1 * step(n1, inData.color) + 0.3 * 
    step(n2, inData.color) + 0.3 * step(n3, inData.color) /*+ 0.6 * step(n4, NL)*/;
    
    //float4 OutColor;
    //if (NL.x < 1.0f / 4)
    //{
    //    OutColor = float4(0 / 3.0f, 0 / 3.0f, 0 / 3.0f, 1.0f);

    //}
    //else if (NL.x < 2.0f / 4)
    //{
    //    OutColor = float4(1 / 3.0f, 1 / 3.0f, 1 / 3.0f, 1.0f);
    //}
    //else if (NL.x < 3.0f / 4)
    //{
    //    OutColor = float4(2 / 3.0f, 2 / 3.0f, 2 / 3.0f, 1.0f);
    //}
    //else
    //{
    //    OutColor = float4(3 / 3.0f, 3 / 3.0f, 3 / 3.0f, 1.0f);
    //}
    
    //inData.color = OutColor;
    
    if (isTextured == false)
    {
        diffuse = diffuseColor * tI * factor.x;
        ambient = diffuseColor * ambentSource ;
    }
    else
    {
        diffuse = g_texture.Sample(g_sampler, inData.uv) * tI * factor.x;
        ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource ;
    }
    return diffuse + ambient;
}