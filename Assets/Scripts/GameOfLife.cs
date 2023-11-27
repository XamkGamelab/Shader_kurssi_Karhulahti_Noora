using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class GameOfLife : MonoBehaviour
{
     [SerializeField] private ComputeShader UVShader;
    [SerializeField] private Material VisualizationMaterial;

    private enum Seed
    {
        FullTexture,
        RPentomino,
        Acorn,
        GosperGun
    }

    [SerializeField] private Seed startSeed;

    [SerializeField] private Color cellColor = Color.red;
    [SerializeField][Range(.05f,3f)] private float updateSpeed;
    private float timer = 0;
    
    private RenderTexture UVTextureOne;
    private RenderTexture UVTextureTwo;

    private static int OneKernel;
    private static int TwoKernel;
    
    private static int FullTexKernel;
    private static int RPentKernel;
    private static int AcornKernel;
    private static int GunKernel;
    
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int UVMap = Shader.PropertyToID("UVMap");

    void Start()
    {
        OneKernel = UVShader.FindKernel("Update1");
        TwoKernel = UVShader.FindKernel("Update2");

        FullTexKernel = UVShader.FindKernel("InitFullTexture");
        RPentKernel = UVShader.FindKernel("InitRPentomino");
        AcornKernel = UVShader.FindKernel("InitAcorn");
        GunKernel = UVShader.FindKernel("InitGun");

        UVTextureOne = new RenderTexture(512, 512, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true
        };
        UVTextureTwo = new RenderTexture(512, 512, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true
        };
        
        UVTextureOne.Create();
        VisualizationMaterial.SetTexture(BaseMap, UVTextureOne);
        
        UVShader.SetTexture(OneKernel, UVMap, UVTextureOne);
        
        UVShader.Dispatch(OneKernel, 512 / 8, 512 / 8, 1);
    }

    private void Update()
    {
        timer += Time.deltaTime;
        if (timer > updateSpeed)
        {
            timer = 0;
        }
    }

    private void OnDisable()
    {
        UVTextureOne.Release();
    }

    private void OnDestroy()
    {
        UVTextureOne.Release();
    }
}
