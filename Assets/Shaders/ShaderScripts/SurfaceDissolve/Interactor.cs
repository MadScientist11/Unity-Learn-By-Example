using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactor : MonoBehaviour
{
    [SerializeField] float radius;
    private bool _disappear;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);


            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                Vector3 worldPosition = hit.point;
                Shader.SetGlobalVector("_Position", worldPosition);
            }

            _disappear = true;
        }

        if (_disappear)
        {
            if (radius > 20)
            {
                radius = 0;
                _disappear = false;
                return;
            }

            Debug.Log("Disapear");

            radius += Time.deltaTime * 5;
        }
        Shader.SetGlobalFloat("_Radius", radius);

    }
}