using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spinner : MonoBehaviour
{
    [SerializeField] private float _rotation;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0f, _rotation * Time.deltaTime, 0f, Space.World);
    }
}
