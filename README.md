# README
## 2018 Spring IPPR Image Reconition/Detection

All members of the group contributed equally to the code and the project overall.

Students:
- 98054998 - Morgan Pollock
- 98081654 - Mikhael El Khoury 
- 12475214 - Gene Lin
- 10900241 - Yangyang(Liz) Liu
- 98117411 - Denise Ounepaseuth
- 12545998 - Max Sekula 


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
  **#Note: Please run the code on a Windows machine, since we notice that some Matlab built-in functions have unstable compiling issues when running on Mac.**


1. [Download the reduced dataset and pretrained classifer](https://drive.google.com/file/d/137w16nvHayK7M7kLAaZsm9CA3cvK9FaC/view?usp=sharing)
- The download includes 3 files in the kth folder that are precomputed. They are:
  - allFiles.mat: contains a list of all video files, their action label and the if they are in the training or test set
  - svmBoWClassifier.mat: containts an SVM classifier trained on the training set from a bag of features
  - svmClassifiedFiles.mat: contains the scores of the test set ready for evaluation
- The jpg folder of pre-processed frames in the training and testing sets is also present. In side of this folder is the bag of features used to train the SVM classifer
2. Unzip the kth zip file and place the kth folder in the C:\ drive *The directories should no appear like C:\kth\avi\{action folders}*
- At this stage the precomputed files can be removed from the kth directory to run the process as they are here to speed up the process..
  - Our suggestion is to keep the allFiles.mat and the jpg folder as the image extraction takes a long time to run. The classifier and classifiedFiles matlab files can be delete and the process run. Upon completion of the process the deleted files will have been replaced with newer version.
3. Modify the root path in the main file if the kth folder was not placed on the C: drive
4. Open and run the main.m file, this can be completed in MATLAB by pressing **F5** when the main file is open . *It is a central file that will call other functions and helper files*
5. Follow the on-screen instructions if any appear and wait for the dataset to finish processing
6. The final output should be an overall accuracy score

#### Video Extraction
The extract video component parses the dataset (KTH Videos) and generates individual JPEG image files from the videos of the video's frames. This is done as the dataset is too large to store and compute the classifier while in memory and allows the code to scale as more datasets are used that require additional memory due to larger frames sizes (image quality).

The PARFOR function as a function of the Parallel Computing Toolbox executes for-loop iterations simultaneously on workers in a parallel pool. In this case, the objective was to extract the image (each frame) while simultaneously reducing the amount of useless data that is preset in the frames. This is completed by resizing the images and converting the B&W videos to greyscale from their RGB components. Additionally, this occurs while running the personDetector function is used to generate a score. In this function, we can detect if there is a person in the frame, and using the scoring to remove any frames that do not contain a person. This will lead to improved processing time and improved accuracy as it reduces the number of frames to analyse.

#### Feature Extraction
Feature extraction is a type of dimensionality reduction that represents significant parts of an image as a compact feature vector. Essentially, feature extraction is useful in the situation where large sized images and a reduced feature representation is required to complete tasks efficiently. Often, feature extraction and feature detection are used in combination to complete tasks such as object detection, recognition and other computer vision problems. Following the extraction of features, it could be built into machine learning models for accurate object recognition and detection. 
In our code and the Vision Toolbox the actual process for generating the bag of features begins by trimming the dataset so that each category has an equal number of samples. It then utilises SURF (Speeded-Up Robust Features) to compute a bag of features which are reduced via k-means clustering, via the bagOfFeatures method.


#### Classifier Creation
The classifier used in this code is an SVM. Support vector machines typically are one of the more accurate classifiers however they do take a longer time to train and classify. The training process involves passing in the bag of features alongside the training set to allow the SVM to optimise the features that distinctively differentiate the classes. In the vision toolbox this is specifically done via the trainImageCategoryClassifier method which has the added benefit of being able to utilise parallel processing to reduce the time taken.

#### Prediction
Prediction is simply a function to be called upon and the precision of the fitness is manually calculated by defined methods. Since the classification is exercised at dataframe (image) level, a data frames of all data frames associated with one image is aggregated for assessment on predicting action. Classification is based on the aggregation of possibility for each video based on the individual classification of the frames. The action with the highest aggregated possibility across all images is classed as the prediction result. Then the final accuracy is measured through the correct prediction. To gain the highest accuracy frames with no action features should not be included, while all frames with the action should be present to reduce bias in the classification.


#### Evaluation 
This is a simple process of computing the confusion matrix for validation and determining which actions are more likely to be misclassifid. Through the matrix, the cross-validation is done assessing the accuracy of the learning task. The classified prediction results are parsed in for analysis to construct a matrix in order to analyze the degree of fitness. The final result is an accuracy score that measures the overall % accuracy of the classifier on the test set.

**The code contains comments for most lines to describe the processes that are taking place**
