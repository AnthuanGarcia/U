using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Pixelate : MonoBehaviour
{
    [SerializeField] float grid = 20f;

    Material material;

    void Awake()
    {
        material = new Material( Shader.Find("Hidden/Pixelate") );
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetFloat("_GridSize", grid);
        Graphics.Blit (src, dest, material);
    }
}
