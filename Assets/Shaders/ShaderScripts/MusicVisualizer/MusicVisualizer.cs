using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MusicVisualizer : MonoBehaviour
{
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private RawImage _image;

    private float[] _samples = new float[512];
    private float[] _sampleBuffer = new float[512];
    private Material _material;
    private static readonly int Samples = Shader.PropertyToID("_Samples");
    private float[] _FreqBands8 = new float[8];
    private float[] _FreqBands64 = new float[64];
    private float _currentDuration = 0;

    private void Start()
    {
        _material = _image.material;
        StartCoroutine(ChartUpdate());
    }
    
    public static float OutElastic(float t)
    {
        float p = 0.3f;
        return (float)Math.Pow(2, -10 * t) * (float)Math.Sin((t - p / 4) * (2 * Math.PI) / p) + 1;
    }
    
    float easeInOutCirc(float t){
        return t < 0.5f
            ? (float)(1f - Math.Sqrt(1 - Math.Pow(2f * t, 2f))) / 2f
            : (float)(Math.Sqrt(1f - Math.Pow(-2f * t + 2f, 2f)) + 1f) / 2f;
    }
    
    public static float InElastic(float t) => 1 - OutElastic(1 - t);
    
    public static float InOutElastic(float t)
    {
        if (t < 0.5) return InElastic(t * 2) / 2;
        return 1 - InElastic((1 - t) * 2) / 2;
    }

    private void Update()
    {
        _currentDuration += Time.deltaTime;
        _audioSource.GetSpectrumData(_sampleBuffer, 0, FFTWindow.BlackmanHarris);


        for (int i = 0; i < _samples.Length; i++)
        {
            _samples[i] = Mathf.Lerp(_samples[i], _sampleBuffer[i],
                easeInOutCirc(_currentDuration));
        }

        UpdateFreqBands64();
    }

    private float Smoothstep()
    {
        return _currentDuration * _currentDuration * (3.0f - 2.0f * _currentDuration);
    }

    private IEnumerator ChartUpdate()
    {
        while (true)
        {
            _currentDuration = 0;
            yield return new WaitForSeconds(1);
        }
    }

    private void UpdateFreqBands8()
    {
        int count = 0;
        for (int i = 0; i < 8; i++)
        {
            float average = 0;
            int sampleCount = (int)Mathf.Pow(2, i) * 2;

            if (i == 7)
            {
                sampleCount += 2;
            }

            for (int j = 0; j < sampleCount; j++)
            {
                average += _samples[count] * (count + 1);
                count++;
            }

            average /= count;
            _FreqBands8[i] = average;
        }

        _material.SetFloatArray(Samples, _FreqBands8);
    }

    void UpdateFreqBands64()
    {
        int count = 0;
        int sampleCount = 1;
        int power = 0;

        for (int i = 0; i < 64; i++)
        {
            float average = 0;

            if (i == 16 || i == 32 || i == 40 || i == 48 || i == 56)
            {
                power++;
                sampleCount = (int)Mathf.Pow(2, power);
                if (power == 3)
                    sampleCount -= 2;
            }

            for (int j = 0; j < sampleCount; j++)
            {
                average += _samples[count] * (count + 1);
                count++;
            }

            average /= count;
            _FreqBands64[i] = average;
        }

        _material.SetFloatArray(Samples, _FreqBands64);
    }
}