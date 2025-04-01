### **Course Assignment: Visual Information Processing and Management**
---

**Assignment 1: Color Transfer & Chroma Keying**

* **Description:** This assignment focused on two techniques:
    1.  **Color Transfer:** Modifying the chromatic components of a source image to match those of a reference image.
    2.  **Chroma Keying (Green Screen):** Replacing the green background of an image with a new background, integrating the subject realistically.
* **Technologies/Methods Used:**
    * Color space conversion (RGB <-> YCbCr) using functions like `rgb2ycbcr` and `ycbcr2rgb`.
    * Calculation of the mean of chromatic channels (Cb, Cr) for color transfer.
    * Color sample extraction (`imcrop`), calculation of color distances, creation and combination of binary masks for chroma keying.
    * Application of Color Transfer to improve integration in chroma keying.
* **Results:** Successfully transferred color characteristics between images and implemented the chroma key effect by replacing a green background and adapting the subject's colors to the new environment.

---

**Assignment 2: Image Interpolation (Demosaicing) & Automatic White Balance (AWB)**

* **Description:** Implementation of algorithms for reconstructing full-color images from raw sensor data (demosaicing) and for automatically correcting the white balance (AWB).
* **Technologies/Methods Used:**
    * **Interpolation:** Iterative approach to estimate missing pixel values based on neighbors (diagonals for Red/Blue, horizontal/vertical for Green).
    * **AWB:** Implementation of Gray World (assumed based on color averaging), WhitePoint (using a D65 white point reference), and WhitePatch (based on maximum RGB values) methods.
* **Results:** The RAW image was correctly interpolated, and various AWB techniques were successfully applied to correct color casts.

---

**Assignment 3: Adaptive Gamma Correction**

* **Description:** Enhancing visibility in underexposed images using local adaptive gamma correction techniques, based on the paper "Local Color Correction Using Non-Linear Masking".
* **Technologies/Methods Used:**
    * Conversion to YCbCr color space to isolate the luminance channel (Y).
    * Creation of a mask based on the inverse of the Y channel.
    * Application of spatial filters to the mask:
        * **Gaussian Filter** (`sigma=15`) for uniform blurring.
        * **Bilateral Filter** (`degreeOfSmoothing=0.05`, `spatialSigma=15`) to preserve edges.
    * Calculation of a variable gamma correction exponent per pixel (`Exponent = 2^((128 - Mask_blurred) / 128)`).
    * Application of the correction to the Y channel, normalization, and conversion back to RGB.
* **Results:** Both techniques significantly improved the local brightness and contrast of the underexposed image, with the bilateral filter preserving fine details better than the Gaussian filter.

---

**Assignment 4: Object Detection and Segmentation using SURF**

* **Description:** Detecting and segmenting a specific object (an elephant) within a complex scene using SURF features and geometric transformations.
* **Technologies/Methods Used:**
    * **SURF** feature detection (`detectSURFFeatures`) with optimized parameters (`MetricThreshold=1000`, `NumOctaves`, `NumScaleLevels`) for the target object.
    * Feature matching between the object image and the scene.
    * Manual selection of object contour points (`ginput`).
    * Estimation of the geometric transformation (`estimateGeometricTransform`) to map the contour onto the scene.
    * Refinement of the mapped contour through scaling (15%) and translation for better overlap.
* **Results:** The elephant object was correctly located in the scene, and its contour was accurately mapped and adjusted.

---

**Assignment 5: Image Classification using Superpixels and SVM**

* **Description:** Implementation of an image classification pipeline based on superpixels and Support Vector Machines (SVM).
* **Technologies/Methods Used:**
    * Segmentation into **Superpixels**.
    * Feature Extraction: Calculation of the mean RGB values for each superpixel.
    * Reading and managing training, validation (`parts_validation.txt`), and test (`parts_test.txt`) data.
    * Training a multi-class **SVM** classifier (`fitcecoc`).
* **Results:** Achieved an accuracy of **75.41%** on the test set and **74.84%** on the validation set, demonstrating the effectiveness of the superpixel and SVM-based approach for this task.

---

**Assignment 6: Image Classification using Bag-of-Words (BoW) and Neural Networks**

* **Description:** Development of an image classification system using the Bag-of-Words (BoW) model with SURF features and a Feedforward Neural Network (FNN) classifier.
* **Technologies/Methods Used:**
    * **SURF** feature extraction on a dense grid (`featStep=10`).
    * Creation of a visual vocabulary using **k-means** clustering (`K=200`).
    * Calculation of normalized **BoW** histograms to represent images.
    * Classification using a **Feedforward Neural Network (FNN)** (`fitcnet`) with automatic hyperparameter optimization (`OptimizeHyperparameters='all'`).
* **Results:** The model achieved an accuracy of **74%** on the test set, showing an improvement over previous approaches due to the use of FNN and denser feature extraction.

---

**Assignment 7: Feature Extraction with Pre-trained CNN (AlexNet) & 1-NN Classification**

* **Description:** Analysis of the effectiveness of features extracted from different layers of a pre-trained Convolutional Neural Network (CNN) (**AlexNet**) for image classification on two distinct datasets (Simplicity and Micro_Organism).
* **Technologies/Methods Used:**
    * Pre-trained Network: **AlexNet**.
    * Feature extraction from intermediate (`conv2`, `relu4`) and deep (`relu7`) layers using `activations`.
    * **L2 Normalization** of extracted features.
    * Classification using **1-Nearest Neighbor (1-NN)** based on Euclidean distance.
    * Datasets: Simplicity (course dataset) and Micro_Organism (Kaggle, different domain).
* **Results:**
    * **Simplicity:** Accuracy increased with layer depth (~68% `conv2`, ~83% `relu4`, **~94% `relu7`**).
    * **Micro_Organism:** Lower accuracy (~34% `conv2`, ~46% `relu4`, **~64% `relu7`**), highlighting the dataset domain dependency and lower generalization of AlexNet on data very different from ImageNet.
    * Confirmed that features from deeper layers are generally more discriminative.

---

**Assignment 8: Fine-Tuning a Pre-trained CNN with Data Augmentation**

* **Description:** Optimizing the performance of a pre-trained CNN (presumably AlexNet) for a specific classification task through fine-tuning the final layer and enhancing data augmentation.
* **Technologies/Methods Used:**
    * Modification of the final **Fully Connected layer** (reducing learning rate factors for weights/biases to 20).
    * Data loading using `imageDatastore` and a 70/30 train/test split.
    * **Data Augmentation:** Increasing the pixel translation range from ±5 to **±10** pixels.
    * Network training using `trainingOptions` (base settings maintained).
* **Results:** A **significant performance improvement** was achieved, primarily attributed to the enhanced **data augmentation** (increased translation range), while modifications to the final layer's learning rates had less impact.
