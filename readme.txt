## Deep Learning Model Runner

This Python code allows you to select and run various Convolutional Neural Network (CNN) architectures on your dataset. It also includes the option to split the main dataset into training and testing datasets, visualize the training data, and plot the label counts for both the training and testing datasets before running the CNN architectures.


## How to Use

1. Download the code files and the main datasets (with images of different genera classes in JPEG format).
2. Ensure that all necessary libraries are installed (see the list of required libraries below).
3. Navigate to the 'train_test_datasets_splits' folder and run the 'train_test_datasets_with_visuals.py' file in a Python IDE or command prompt. This step will provide the training and testing datasets, generate a CSV file containing labels of the generated data, and visualize the training data.
4. Move to the 'train_test_datasets_count_plots' folder and run the 'train_test_plot_combined.py' script on the generated CSV file. This will plot the label counts for both the training and testing datasets.
5. Proceed to the CNN Architectures Plot folder and run the different models ('densenet.py', 'efficientnet.py', 'inception_v3.py', 'mobilenet_v2.py', 'resnet50.py', and 'vgg16.py') on the training and testing datasets generated.
6. Wait for the models to finish running.
7. After the models have finished running, you can choose to display comparison plots for the evaluated metrics between models (codes for the comparison plots are provided in 'metrics_comparison.py').
8. Exit the program by pressing any button when prompted.


## Files

The following files are included in this code:

- 'train_test_datasets_with_visuals.py': Provides training and testing datasets, generates a CSV file containing labels, and visualizes the training data.
- 'train_test_plot_combined.py': Plots the label counts for both the training and testing datasets.
- 'densenet.py': Implements the DenseNet CNN architecture for deep learning.
- 'efficientnet.py': Implements the EfficientNet CNN architecture for deep learning.
- 'inception_v3.py': Implements the InceptionV3 CNN architecture for deep learning.
- 'mobilenet_v2.py': Implements the MobileNetV2 CNN architecture for deep learning.
- 'resnet50.py': Implements the ResNet50 CNN architecture for deep learning.
- 'vgg16.py': Implements the VGG16 CNN architecture for deep learning.
- 'metrics_comparison.py': Contains code to display comparison plots for the evaluated metrics between models.
- 'combine_confusionmatrix_images.py': Combines the confusion matrix images generated from different CNN architectures.
- 'combine_losscurves_images.py': Combines the loss curves images generated from different CNN architectures.


## Required Libraries

This code requires the following libraries (make sure to install the libraries you don't have):

- os
- matplotlib.pyplot
- pandas
- cv2 (OpenCV)
- numpy as np
- sklearn
- tensorflow
- tensorflow.keras.utils
- PIL (Python Imaging Library)


## Credits

This code was created by Daniel Gyamfi Amoako as part of the final research project. 

#The End of the work.

#Thank you



