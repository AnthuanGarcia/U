using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public static PlayerController Controller;

    [SerializeField] private float _stepSize = 2f;
    [SerializeField] private float _speed = 1f;

    private bool _canMove = false;
    public bool CanMove{set => _canMove = value;}
    //[SerializeField] private float _speed = 5f, _maxVel = 10f;
    //[Range(0, .3f)] [SerializeField] private float _movementSmoothing = .05f;
    //[SerializeField] private LayerMask _groundMask;

    //Matrix4x4 IsoMat = Matrix4x4.Rotate(Quaternion.Euler(0, 90, 0));

    //Vector3 zero = Vector3.zero;

    Vector3 _input;
    bool _hasStep;

    void Awake()
    {
        Controller = this;
    }

    void Start()
    {
        _hasStep = true;
    }

    void Update()
    {
        if (_canMove)
            getInput();
    }

    void FixedUpdate()
    {
        if (_hasStep)
        {
            Vector3 down = transform.TransformDirection(Vector3.down);

            if (!Physics.Raycast(transform.position, down, 20f) && _canMove)
            {
                KillPlayer.Instance.Kill();
            }
        }
    }

    void getInput()
    {
        _input = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));

        if (Mathf.Abs(_input.x) > 0f)
        {
            _input.x = Mathf.Round(_input.x);
            _input.z = 0f;
            move();
        }
        else if (Mathf.Abs(_input.z) > 0f)
        {
            _input.x = 0f;
            _input.z = Mathf.Round(_input.z);
            move();
        }

        /*if ((Mathf.Abs(_input.x) > 0f || Mathf.Abs(_input.z) > 0f) && hasStep)
        {
            _input = new Vector3(
                Mathf.Round(_input.x), 0, Mathf.Round(_input.z)
            ) * _stepSize;

            _input = Vector3.ClampMagnitude(_input, _stepSize);

            StartCoroutine(Step());
        }*/

    }

    /*Vector3 getMousePosition()
    {
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out var hitInfo, Mathf.Infinity, _groundMask))
        {
            return hitInfo.point;
        }

        return Vector3.zero;

    }*/

    void move()
    {

        //var intInput = new Vector3(
        //    Mathf.Round(_input.x), 0, Mathf.Round(_input.z)
        //);

        //transform.position += intInput * _stepSize;

        if (_hasStep)
        {            
            StartCoroutine(Step());
            Manager.Instance.MoveEnemies();
        }

    }

    IEnumerator Step()
    {
        _hasStep = false;

        float travelPercentage = 0f;

        Vector3 initPos = transform.position;
        Vector3 finalPos = initPos + _input * _stepSize;

        while(travelPercentage < 1f)
        {
            travelPercentage += Time.deltaTime * _speed;
            
            transform.position = Vector3.Lerp(
                initPos, finalPos, Mathf.SmoothStep(0f, 1f, travelPercentage)
            );

            yield return new WaitForEndOfFrame();
        }

        _hasStep = true;

    }

}
