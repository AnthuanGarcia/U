using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Utils
{
    public static Vector3 roundToEvenCoords(Vector3 pos)
    {
        var intPos = new Vector3Int(
            Mathf.RoundToInt(pos.x), 0, Mathf.RoundToInt(pos.z)
        );

        intPos.x += intPos.x & 1;
        intPos.z += intPos.z & 1;

        return intPos;
    }
}
