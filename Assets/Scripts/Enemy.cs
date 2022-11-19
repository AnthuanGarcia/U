using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Enemy : MonoBehaviour
{
    public float _speed = 3f;
    public float _stepSize = 2f;

    public abstract void Move();

}
