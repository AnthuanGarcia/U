using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FooEnemy : Enemy
{
    //[SerializeField] private float _speed = 3f;
    //[SerializeField] private float _timeToStep = 0.25f;
    //[SerializeField] private float _stepSize = 2f;
    bool _hasStep = true;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
    }

    /*void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            StopCoroutine(Step(Vector3.zero));

            var dir = roundToEvenCoords(
                (transform.position - other.contacts[0].point).normalized
            );

            transform.position = roundToEvenCoords(transform.position);

            StartCoroutine(Step(dir));

        }
    }*/

    public override void Move()
    {
        if (_hasStep)
        {
            Vector3 down = transform.TransformDirection(Vector3.down);

            if (!Physics.Raycast(transform.position, down, 2f))
            {
                transform.Rotate(
                    Vector3.right * 90f, Space.Self
                );

            }

            StartCoroutine(Step());

        }
    }

    IEnumerator Step()
    {
        _hasStep = false;

        float travelPercentage = 0f;

        Vector3 initPos = transform.position;
        Vector3 finalPos = initPos + transform.forward * _stepSize;

        while(travelPercentage < 1f)
        {
            travelPercentage += Time.deltaTime * _speed;
            //transform.position = Vector3.Lerp(initPos, finalPos, travelPercentage);
            transform.position = Vector3.Lerp(initPos, finalPos, Mathf.SmoothStep(0f, 1f, travelPercentage));
            yield return new WaitForEndOfFrame();
        }

        //yield return new WaitForSeconds(_timeToStep);

        _hasStep = true;

    }
}
