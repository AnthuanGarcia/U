using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransitionGround : MonoBehaviour
{
    [SerializeField] private GameObject _movables;
    [SerializeField] private Vector3 _movementDir;
    [SerializeField] private float _offsetTime = 0.5f;
    [SerializeField] private float _speed = 5f;
    [SerializeField] private Vector3 _positionPlayer;

    List<GameObject> initialPos = new List<GameObject>();
    List<Vector3> originalPos = new List<Vector3>();
    List<Quaternion> originalRot = new List<Quaternion>();

    // Start is called before the first frame update
    void Awake()
    {
        foreach(Transform cube in transform)
        {
            initialPos.Add(cube.transform.gameObject);
        }

        foreach(Transform cube in _movables.transform)
        {
            initialPos.Add(cube.transform.gameObject);
            originalPos.Add(cube.transform.position);
            originalRot.Add(cube.transform.rotation);
        }

        initialPos.Add(PlayerController.Controller.gameObject);
    }

    public void EntryCubes()
    {
        print(initialPos.Count);
        StartCoroutine(moveCubes());
    }

    public void ExitCubes()
    {
        StartCoroutine(exitCubes());
    }

    IEnumerator exitCubes()
    {
        PlayerController.Controller.CanMove = false;

        for(int i = initialPos.Count - 1; i >= 0; i--)
        {
            StartCoroutine(Step(initialPos[i], -1));
            yield return new WaitForSeconds(_offsetTime);
        }

        yield return new WaitForSeconds(0.5f);

        //StartCoroutine(Manager.Instance.LoadNextLevel());
        Manager.Instance.NextLevel();
        ResetPositions();

    }

    IEnumerator moveCubes()
    {
        PlayerController.Controller.CanMove = false;

        for(int i = 0; i < initialPos.Count; i++)
        {
            StartCoroutine(Step(initialPos[i], 1));
            yield return new WaitForSeconds(_offsetTime);
        }

        yield return new WaitForSeconds(0.5f);

        PlayerController.Controller.CanMove = true;
        Manager.Instance.SetFollowPlayer();
    }

    void ResetPositions()
    {
        int size = initialPos.Count - 1;
        int i = 0;

        foreach(Transform obj in _movables.transform)
        {
            obj.position = originalPos[i];
            obj.rotation = originalRot[i];
            i++;
        }

        initialPos[size].transform.position = _positionPlayer;

    }

    IEnumerator Step(GameObject cube, float sign)
    {
        float travelPercentage = 0f;

        Vector3 initPos  = cube.transform.position;
        Vector3 finalPos = initPos + _movementDir * sign;

        while(travelPercentage < 1f)
        {
            travelPercentage += Time.deltaTime * _speed;
            //transform.position = Vector3.Lerp(initPos, finalPos, travelPercentage);
            cube.transform.position = Vector3.Lerp(
                initPos, finalPos, Mathf.SmoothStep(0f, 1f, travelPercentage)
            );
            
            yield return new WaitForEndOfFrame();
        }
    }
}
