using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class SceneViewer : EditorWindow
{
    private const float Speed = 2;
    private const float Step = 1;
    private const float ButtonHeight = 27;
    private const float ButtonWidth = 300;
    private const float MinHue = 0.1f; // need it to exclude black from the color animation range

    [MenuItem("Window/Scene Viewer")]
    private static void Open()
    {
        var sceneViewer = GetWindow<SceneViewer>();
        sceneViewer.maxSize = new Vector2(400, 1000);
    }

    [ContextMenu("CONTEXT/SceneViewer/DOSomething")]
    private static void DoSomething()
    {
        Debug.Log("Perform operation");
    }

    private void OnEnable() => EditorApplication.update += Repaint;
    private void OnDisable() => EditorApplication.update -= Repaint;

    private void OnGUI()
    {
        var buildScenes = EditorBuildSettings.scenes;
        var guids = AssetDatabase.FindAssets("t:Scene");

        if (guids.Length == 0)
        {
            GUILayout.Label("No Scenes Found", EditorStyles.centeredGreyMiniLabel);
        }

        var time = (float)EditorApplication.timeSinceStartup;
        var displaySceneIndex = 0;

        foreach (var guid in guids)
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>(path);
            var sceneToDisplay = buildScenes.FirstOrDefault(editorBuildScene => editorBuildScene.path == path);


            if (sceneToDisplay == null) continue;

            var hue = MinHue + Mathf.Repeat(.8f * time, 1) + displaySceneIndex * -.04f;
            GUI.color = Color.HSVToRGB(hue, 1, 1);
            var btnRect = new Rect(0,
                (ButtonHeight * displaySceneIndex) + (displaySceneIndex * EditorGUIUtility.standardVerticalSpacing),
                ButtonWidth, ButtonHeight);
            var clampedWidth = Mathf.Clamp(position.width, ButtonWidth, 400);
            btnRect.x = (Mathf.Sin(time * Speed + (-Step * displaySceneIndex)) + 1) * (clampedWidth - ButtonWidth) / 2;
            if (GUI.Button(btnRect, sceneAsset.name))
            {
                Open(path);
            }

            displaySceneIndex++;
        }
    }

    private static void Open(string path)
    {
        if (EditorSceneManager.EnsureUntitledSceneHasBeenSaved(
                "You don't have saved the Untitled Scene, Do you want to leave?"))
        {
            EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo();
            EditorSceneManager.OpenScene(path, OpenSceneMode.Single);
        }
    }
}