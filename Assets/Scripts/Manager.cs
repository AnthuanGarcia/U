using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Cinemachine;

public class Manager : MonoBehaviour
{
    public static Manager Instance;
    [SerializeField] private float _timeToReset = 2.5f;
    public FooEnemy[] EnemiesFollowing;
    public Color[] LevelBackground;
    public int TotalLevel = 2;
    public GameObject[] Levels, FinishPoints;
    public BackGroundManager backGroundManager;
    public CinemachineVirtualCamera virtualCamera;

    Transform lookPoint;
    int currentLevel = 0;
    
    void Awake()
    {
        Instance = this;
    }

    void OnEnable()
    {
        //entryTransition();
    }

    // Start is called before the first frame update
    void Start()
    {
        EnemiesFollowing = FindObjectsOfType<FooEnemy>();
        //Levels[currentLevel].SetActive(true);
        Levels[currentLevel].GetComponentInChildren<TransitionGround>().EntryCubes();
        lookPoint = GameObject.FindGameObjectWithTag("Look").transform;
    }

    public void MoveEnemies()
    {
        foreach (var enemy in EnemiesFollowing)
        {
            if (enemy.isActiveAndEnabled)
                enemy.Move();
        }
    }

    public void PassLevel()
    {
        virtualCamera.Follow = lookPoint;
        Levels[currentLevel].GetComponentInChildren<TransitionGround>().ExitCubes();
    }

    public void ResetLevel()
    {
        StartCoroutine(resetLevel());
    }

    IEnumerator resetLevel()
    {        
        yield return new WaitForSeconds(_timeToReset);
        
        int idxCurrentLevel = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(idxCurrentLevel);
    }

    public Color NextColor()
    {
        return LevelBackground[(currentLevel + 1) % TotalLevel];
    }

    public void NextLevel()
    {
        int nextLevel = (currentLevel + 1) % TotalLevel;

        Levels[nextLevel].SetActive(true);

        var ground = Levels[nextLevel].GetComponentInChildren<TransitionGround>();
        
        ground.EntryCubes();

        EnemiesFollowing = FindObjectsOfType<FooEnemy>();
        Manager.Instance.backGroundManager.NextColor();

        //PlayerController.Controller.transform.position = initialPos[nextLevel];

        Levels[currentLevel].SetActive(false);
        FinishPoints[currentLevel].SetActive(true);
        currentLevel = nextLevel;

    }

    public void SetFollowPlayer()
    {
        virtualCamera.Follow = PlayerController.Controller.transform;
    }

}
