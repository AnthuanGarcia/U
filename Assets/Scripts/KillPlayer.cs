using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class KillPlayer : MonoBehaviour
{
    public static KillPlayer Instance;
    [SerializeField] private float _pushForce = 30f;

    void Awake()
    {
        Instance = this;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Kill()
    {
        var player = PlayerController.Controller.gameObject;

        player.GetComponent<PlayerController>().enabled = false;

        var rb = player.GetComponent<Rigidbody>();
        rb.constraints = RigidbodyConstraints.None;

        Manager.Instance.ResetLevel();

    }

    void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            other.gameObject.GetComponent<PlayerController>().enabled = false;

            var rb = other.gameObject.GetComponent<Rigidbody>();
            rb.constraints = RigidbodyConstraints.None;

            var dir = (transform.position - other.transform.position).normalized;

            dir.y *= Random.Range(0.25f, 0.8f);

            rb.AddForce(-dir * _pushForce, ForceMode.Impulse);

            Manager.Instance.ResetLevel();
        }
    }
}
