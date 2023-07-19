using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class HeartDemo : MonoBehaviour
{
    [SerializeField] private Image _heartImage;
    [SerializeField] private float _maxHealth;
    [SerializeField] private float _damage;

    private float _currentHealth;

    private void Start()
    {
        _currentHealth = _maxHealth;
        SetHealthProperty();
    }

    public void OnClick_HitButton()
    {
        _currentHealth -= _damage;
        StartCoroutine(HitAnimation());
        SetHealthProperty();
    }

    public void OnClick_RestoreButton()
    {
        _currentHealth = _maxHealth;
        SetHealthProperty();
    }

    private IEnumerator HitAnimation()
    {
        float _shape = -0.2f;

        while(_shape < 0 )
        {
            yield return null;
            _shape += Time.deltaTime;

            _heartImage.material.SetFloat("_shape", _shape);

        }

    }

    private void SetHealthProperty()
    {
        _heartImage.material.SetFloat("_health", _currentHealth / _maxHealth);

    }
}
