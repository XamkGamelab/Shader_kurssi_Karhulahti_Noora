using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class GameOfLife : MonoBehaviour
{
    private enum Seeds
    {
        RPentomino,
        Acorn,
        GosperGun,
        FullTexture
    }
    
    [SerializeField] private ComputeShader Simulator;
    [SerializeField] private Material PlaneMaterial;
    //[SerializeField] private GameInit Seed;
    [SerializeField] private Seeds Seed;
    [SerializeField] private Color CellCol;
    [SerializeField][Range(0f,2f)] private float UpdateInterval;
    
    private float NextUpdate = 2f;

    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);
    
    private RenderTexture State1;
    private RenderTexture State2;

    private bool IsState1;
    
    private static int Update1Kernel;
    private static int Update2Kernel;
    
    private static int FullTexKernel;
    private static int RPentKernel;
    private static int AcornKernel;
    private static int GunKernel;
    
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColour = Shader.PropertyToID("CellColour");
    private static readonly int TextureSize = Shader.PropertyToID("TextureSize");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");

    void Start()
    {
        State1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };

        State1.Create();

        State2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };

        State2.Create();
        
        Update1Kernel = Simulator.FindKernel("Update1");
        Update2Kernel = Simulator.FindKernel("Update2");
        RPentKernel = Simulator.FindKernel("InitRPentomino");
        AcornKernel = Simulator.FindKernel("InitAcorn");
        GunKernel = Simulator.FindKernel("InitGun");
        FullTexKernel = Simulator.FindKernel("InitFullTexture");
        
        Simulator.SetTexture(Update1Kernel, State1Tex, State1);
        Simulator.SetTexture(Update1Kernel, State2Tex, State2);
        
        Simulator.SetTexture(Update2Kernel, State1Tex, State1);
        Simulator.SetTexture(Update2Kernel, State2Tex, State2);
        
        Simulator.SetTexture(RPentKernel, State1Tex, State1);
        Simulator.SetTexture(AcornKernel, State1Tex, State1);
        Simulator.SetTexture(GunKernel, State1Tex, State1);
        Simulator.SetTexture(FullTexKernel, State1Tex, State1);
        
        Simulator.SetVector(CellColour, CellCol);
        
        //bonus:
        Simulator.SetVector(TextureSize, new Vector4(TexSize.x, TexSize.y));

        switch (Seed)
        {
            case Seeds.RPentomino:
                Simulator.Dispatch(RPentKernel,TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.Acorn:
                Simulator.Dispatch(AcornKernel,TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.GosperGun:
                Simulator.Dispatch(GunKernel,TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.FullTexture:
                Simulator.Dispatch(FullTexKernel,TexSize.x / 8, TexSize.y / 8, 1);
                break;
            default:
                break;
        }

        Simulator.Dispatch(Seed switch
        {
            Seeds.RPentomino => Simulator.FindKernel("InitRPentomino"),
            Seeds.Acorn => Simulator.FindKernel("InitAcorn"),
            Seeds.GosperGun => Simulator.FindKernel("InitGun"),
            Seeds.FullTexture => Simulator.FindKernel("InitFullTexture"),
            _ => 0
        }, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void Update()
    {
        if (Time.time < NextUpdate) return;
        
        IsState1 = !IsState1;
        
        PlaneMaterial.SetTexture(BaseMap, IsState1 ? State1 : State2);

        NextUpdate = Time.time + UpdateInterval;
    }

    private void OnDisable()
    {
        State1.Release();
        State2.Release();
    }

    private void OnDestroy()
    {
        State1.Release();
        State2.Release();
    }
}