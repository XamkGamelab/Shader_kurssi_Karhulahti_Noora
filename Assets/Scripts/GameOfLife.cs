using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class GameOfLife : MonoBehaviour
{
    private enum Seed
    {
        FullTexture,
        RPentomino,
        Acorn,
        GosperGun
    }

    [SerializeField] private ComputeShader simulator;
    [SerializeField] private Material planeMaterial;
    [SerializeField] private Seed seed;
    [SerializeField] private Color cellCol = Color.magenta;
    [SerializeField] [Range(0f, 2f)] private float updateInterval;

    private float _nextUpdate = 0;
    private bool _isState1 = true;

    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);

    private RenderTexture _state1;
    private RenderTexture _state2;

    private static int _update1Kernel;
    private static int _update2Kernel;
    private static int _seedKernel;

    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColor = Shader.PropertyToID("CellColor");
    private static readonly int TextureSize = Shader.PropertyToID("TextureSize");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");
    private static readonly int WrapBool = Shader.PropertyToID("WrapBool");

    private void Awake()
    {
        CreateRenderTextures();
        FindKernels();
        InitializeSimulation();
    }

    private void CreateRenderTextures()
    {
        _state1 = CreateRenderTexture();
        _state2 = CreateRenderTexture();
        planeMaterial.SetTexture(BaseMap, _state1);
    }

    private RenderTexture CreateRenderTexture()
    {
        RenderTexture texture = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        texture.Create();
        return texture;
    }

    private void FindKernels()
    {
        _update1Kernel = simulator.FindKernel("Update1");
        _update2Kernel = simulator.FindKernel("Update2");

        _seedKernel = seed switch
        {
            Seed.FullTexture => simulator.FindKernel("InitFullTexture"),
            Seed.RPentomino => simulator.FindKernel("InitRPentomino"),
            Seed.Acorn => simulator.FindKernel("InitAcorn"),
            Seed.GosperGun => simulator.FindKernel("InitGun"),
            _ => 0
        };

        simulator.SetTexture(_update1Kernel, State1Tex, _state1);
        simulator.SetTexture(_update1Kernel, State2Tex, _state2);

        simulator.SetTexture(_update2Kernel, State1Tex, _state1);
        simulator.SetTexture(_update2Kernel, State2Tex, _state2);

        simulator.SetTexture(_seedKernel, State1Tex, _state1);
        simulator.SetTexture(_seedKernel, State2Tex, _state2);

        simulator.SetVector(CellColor, cellCol);

        // Bonus:
        simulator.SetVector(TextureSize, new Vector4(TexSize.x, TexSize.y));
        simulator.Dispatch(_seedKernel, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void InitializeSimulation()
    {
        switch (seed)
        {
            case Seed.FullTexture:
                InitializeFullTexture();
                break;
            case Seed.RPentomino:
                InitializeRPentomino();
                break;
            case Seed.Acorn:
                InitializeAcorn();
                break;
            case Seed.GosperGun:
                InitializeGosperGun();
                break;
            default:
                break;
        }
    }

    private void InitializeFullTexture()
    {
        simulator.Dispatch(_seedKernel, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void InitializeRPentomino()
    {
        simulator.Dispatch(_seedKernel, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void InitializeAcorn()
    {
        simulator.Dispatch(_seedKernel, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void InitializeGosperGun()
    {
        simulator.Dispatch(_seedKernel, TexSize.x / 8, TexSize.y / 8, 1);
    }

    private void Update()
    {
        _nextUpdate += Time.deltaTime;
        if (_nextUpdate > updateInterval)
        {
            UpdateSimulation();
            _nextUpdate = 0;
        }
    }

    private void UpdateSimulation()
    {
        planeMaterial.SetTexture(BaseMap, _isState1 ? _state1 : _state2);
        int currentKernel = _isState1 ? _update1Kernel : _update2Kernel;
        simulator.Dispatch(currentKernel, TexSize.x / 8, TexSize.y / 8, 1);

        _isState1 = !_isState1;
    }

    private void OnDisable()
    {
        ReleaseRenderTextures();
    }

    private void OnDestroy()
    {
        ReleaseRenderTextures();
    }

    private void ReleaseRenderTextures()
    {
        _state1.Release();
        _state2.Release();
    }
}