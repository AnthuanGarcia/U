using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackGroundManager : MonoBehaviour
{
    public static BackGroundManager Instance;

    Color currentColor;

    void Awake()
    {
        Instance = this;
        currentColor = Camera.main.backgroundColor;
    }

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void NextColor()
    {
        StartCoroutine(setColor(Manager.Instance.NextColor()));
    }

    IEnumerator setColor(Color newColor)
    {
        Color lastColor = currentColor;

        float p = 0f;

        while (p < 1f)
        {
            p += Time.deltaTime;
            Camera.main.backgroundColor = Color.Lerp(lastColor, newColor, p);
            yield return new WaitForEndOfFrame();
        }

        currentColor = newColor;
    }


}
