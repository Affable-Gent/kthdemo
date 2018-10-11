# ReadMe
## 2018 Spring IPPR Image Reconition/Detection

All members of the group contributed equally to the code and the project overall.

Students:
- 98054998 - Morgan Pollock
- 98081654 - Mikhael El Khoury 
- 12475214 - Gene Lin
- 10900241 - Yangyang(Liz) Liu
- 98117411 - Denise Ounepaseuth
- XXXXXXXX - Max Sekula 


### Workspace Setup and folder
There are 2 required MATLAB toolboxes required for this action recognition process.
- [Computer Vision System Toolbox](https://au.mathworks.com/help/vision/)
- [Statistics and Machine Learning Toolbox](https://au.mathworks.com/help/stats/)

Additionally to improve performance when running on a multi-threaded machine the following toolbox will help to speed up the process of many of the steps in the process.

+ [Parallel Computing Toolbox](https://au.mathworks.com/help/distcomp/)

The folder structure required for the classifier and dataset is as follows. Ideally the root directory is the C:/ drive as this means no variables need to be changed.

The KTH dataset was used for this classifier and is available here: [http://www.nada.kth.se/cvap/actions/](http://www.nada.kth.se/cvap/actions/)

C:\kth\avi\walking\{walking videos.avi}
The structure denoted by the variables is rootpath\datasetName\{avi and jpeg folders}

The avi folder must exist and contain folders labelled with each of the actions. For example, the KTH dataset when extracted from the downloaded zip files contains 6 folders each with the action label as the folder name. The code with will pull the folder names to label the videos and hence changing these folder names will change the label.

### Instructions to run



#### Video Extraction


#### Feature Extraction


#### Classifier Creation


#### Prediction


#### Evaluation 

