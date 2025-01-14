//───────────────────────────────────────
 // テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); //テクスチャー
SamplerState g_sampler : register(s0); //サンプラー

Texture2D g_toon_texture : register(t1);
SamplerState g_toon_sampler : register(s1);

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
    float4 eyev : POSITION;
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
float4 VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL) : SV_Position
{
	//ピクセルシェーダーへ渡す情報
    //float4 outPos;
	
    normal.w = 0;
    pos = pos + normal * 0.1;
    
    pos= mul(pos, matWVP);
    
	//まとめて出力
    return pos;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
    return float4(0, 0, 0, 1.0);
}