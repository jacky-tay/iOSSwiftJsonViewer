# iOSSwiftJsonViewer

JSON Viewer is a viewContoller that display JSON data for an iOS device.

It support basic search query which filter 

To call for the controller, simply follow the code below:
```
if let viewController = JSONViewerViewController.getViewController(jsonContent) {
  navigationController?.pushViewController(viewController, animated: true)
}
```
