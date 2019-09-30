# MSERTrack
A MATLAB computer vision program which quickly and accurately tracks cells through live cell timelapse fluorescence microscopy movies

# MSERTrack User Guide

**Contents:**

1. About
2. Installation
3. Using the GUI
4. Parameter selection
5. Experimental design tips to improve performance
6. Licensing, acknowledgements and citing**

## 1. About

MSERTrack is a fast and accurate way to track cells through live cell timelapse fluorescence
microscopy movies. This tracking data is then used to quantify the nuclear translocation of
fluorescently labelled proteins of interest. MSERTrack is written in MATLAB and packaged
as a MATLAB application. MSERTrack was created as part of my dissertation towards my
MSc Bioinformatics (University of Manchester).
MSERTrack combines MSER (a popular computer vision algorithm) with a
nearest-neighbour search to track fluorescently labelled nuclei. It then uses the
segmentation and tracking results to quantify the translocation of a protein of interest, such
as a transcription factor. The development of the method is detailed in my dissertation, which
can be accessed ​here​.

## 2. Installation

**System requirements**
* An up-to-date MATLAB installation. R2016b (9.1) or later required.
* The following MATLAB Toolboxes:
* Image Processing Toolbox (R2016b v9.5 or later)
* Computer Vision System Toolbox (R2016b 7.2 or later)
**Install app**
* Download the app installer (MSERTrack.mlappinstall)
* Open MATLAB and navigate to the Apps tab. Select ‘Install App’ and navigate to the
* app installer in your files.
* The app will install and be added to your MATLAB apps panel.

## 3. Using the GUI

The GUI loads in multiple microscope images (in Zeiss LSM format), extracts the relevant
frames and then tracks nuclei through the time course.

**Preview of the main GUI window:**

![](https://github.com/lvass/MSERTrack/blob/master/gui.jpg)



To set up for running MSERTrack, create a folder with the .lsm images you want to analyse.
If there is more than one image in the folder (eg. multiple locations under the same
conditions), the results from these will be combined.

**1. Name the analysis a memorable name. Don’t use any special characters. The**
    **analysis data will be saved in a folder with this name.**

**2. Load experiment:**
    
a. Enter the number of laser channels used in the experiment (minimum of 3,
       maximum of 6).
    
b. Press ‘Select .lsm image folder’ and navigate to the folder you created
       containing the image files you want to analyse.
    
c. A pop-up window will then show a preview of each channel. Enter the position
       of the ‘protein of interest’ stain channel and nuclear stain channel in the
       corresponding text boxes.
    
d. Press ‘Confirm and Extract’ and wait while the image data is extracted and
       saved in the analysis folder.
    
e. Alternatively, to prevent having to repeat these steps when re-analysing with
       different parameters, press ‘re-analyse’ and select the analysis folder (named
       in step 1, should contain multiple analysis results folders and an
       ‘extractedIms’ folder). Re-analysis results will be saved in a new folder with
       the name ‘analysis_date_time’ to prevent overwriting.


**3. Choose parameters:**
    
a. Parameters are initially set to default parameters. These can be tested on the
       first frame of the nuclear channel by pressing ‘test’. The pop-up will show the
       results of the last parameter set in comparison to the new parameter set. Pink
       indicates identified nuclei, blue is holes filled by the algorithm and red is nuclei
       which have been rejected due to shape/size. (More information in ​ **Parameter**
       **selection** ​)
    
b. When you have found a good parameter set, press ‘save’ to save it.

**4. Track cells:**
    
a. Enter the frame you would like to start and end tracking at. Minimum number
       of frames is 10.
    
b. Select movement tolerance between frames (‘Small’ is recommended)
    
c. Enable/disable the frame skip feature with the check box
    
d. Press ‘Track cells’ and wait whilst the cells are tracked. A wait bar shows the
       progress of tracking through each image.
    
e. If the number of cells tracked reaches zero, the analysis will stop and a
       warning message will show. Re-run the analysis with different parameters, a
       shorter time course or with a larger movement tolerance. (More information in
       **Parameter selection** ​)
    
f. When analysis ends, the tracking performance and nuclei intensity will be
       plotted.

**5. Results:**
    
a. The first plot shows the number of nuclei found the each frame and the
       number of nuclei successfully tracked on each frame. Loss of tracking due to
       poor segmentation, nuclei moving out of focus or off frame or clustering of
       nuclei causes the number of cells tracked to decrease through the time
       course.
    
b. The second plot shows the nuclei intensity of cells which were successfully
       tracked throughout the whole time course.
   
c. The ‘refresh’ button can be used to plot the remaining cells in the sample
       (after removing errant tracks).

**6. Analysis:**
    
a. Perform manual checking: Opens a new window where the intensity of each
       cell tracked can be plotted separately.
    
b. ‘Plot all’ plots the whole sample.
    
c. ‘Perform manual check’ can be used to assess the tracking accuracy of an
       individual cell. You might choose to manually check all cells to ensure 100%
       accuracy of the results, or to investigate intensity plots which look unusual.
          
i. A new window will open showing the first 8 nuclear channel images of the analysis (note, the display shows 1 quadrant of the microscope image only). The tracked nuclei is surrounded by a red box. Pressing ‘next’ will advance you through the time course.
         
ii. If the tracking is incorrect or the cell is unusual, you may want to remove the cell from the sample by pressing ‘Remove track from sample’. Note: on returning to the ‘Check cells’ window, you can view the remaining cells by pressing ‘Plot all’. However, the removed cell will still show up in the listbox.

iii. Manual checking also allows easy identification of cell events such as
division or death.

d. When you’re finished, close the window.

**7. Saving and exporting data:**
    
a. Only press ‘save and export’ when you are finished with the analysis.
    
b. This could take a while for large cell samples. The GUI window will close
       when finished.
    
c. Results will be saved in a subfolder of the experiment named
       ‘analysis_date_time’. The folder will contain;

i. Image of the intensity results graph

ii. CVS files containing the intensity and performance data (these can
then be opened in Excel and further analysed)

iii. Text file noting the MSER algorithm parameters used

iv. Matlab .mat file containing variables from the analysis - intensity
results, completely history of each cell tracked etc.

## 4. Parameter selection

**MSER algorithm parameters explained**
The MSER algorithm has 4 parameters which influence performance;
* Maximum area variation (MAV): controls which range of threshold values are defined as ‘stable’. Increasing the MAV value will return more regions, but these regions may be less stable and might pick up noise or abnormalities in the image such as a non-homogeneous nuclear stain.
* Threshold delta (TD): This is the amount at which the binarization threshold is incremented across the image to produce the different levels. A large TD is less computationally intensive but will return fewer regions, whereas a smaller TD value will return more MSER regions.
* Eccentricity limit: This is how spherical the nuclei returned are. Those which are too elliptical in shape will be rejected. 0 is a perfect circle.
* Maximum/minimum nuclei area: measured in micrometers, the expected 2D area of the nuclei. The average area of an animal cell nuclei is 30 micrometers. Decreasing the range might prevent debris being identified as nuclei.

(See dissertation Methods section for more details on parameters)

The best performing parameters in testing have been set as the default parameters. To
return more regions (but increase the chance of false-positives), increase the MAV and and
decrease TD. 

**Parameter Default Recommended range**

Threshold delta 			2.0 0.8 - 2.0 

Maximum area variation 		        0.1 0.1 - 0.75 

Eccentricity limit 			0.8 0.8 - 1.0 

Min/max area (um) 			15 - 40 (75% - 125% of the expected area of a 2D nuclei) 


**Tracking algorithm parameters explained**

* **Movement tolerance between frames:** ​ this is the amount of movement allowed by
a cell frame-to-frame. This should be adjusted depending on the time between
frames, the motility of the cells and the size of the nuclei. The ‘small’ tolerance in
recommended for the best accuracy. Small, medium and large tolerances allow
30um, 40um and 50um of movement respectively. (Note: The tracking algorithm will
always match the nuclei with the closest nuclei in distance in the next frame.)

* **Frame skip feature:** ​allows nuclei to ‘disappear’ from the tracking for one frame. This
feature has been shown to prevent high cell drop-out rates and therefore allow more
cells to be successfully tracked throughout the experiment. This is because often a
nuclei can be missegmented due to loss of focus or clustering for 1 frame, before
returning in the next frame.
** For the best accuracy, disable this feature.
** To maximise the number of cells tracked, turn this feature on.

## 5. Experimental design tips to improve performance

In testing, some cells were tracked for up to 22 hours. The quality of tracking is very
dependent on the quality of the images used.
Best results will be obtained by using;
* Low cell density. Clustered cells can lead to the mis-segmentation of nuclei.
* A homogeneous fluorescent nuclear marker which has good contrast to the background. Image pre-processing might improve the contrast of poorer experiments. In testing, H2B and hoechst performed equally well.
*  Cells with low motility.
* Good focus on nuclei and little movement in the ‘z’ plane.
*  Preferably little cell growth/death.

## 6. Licensing, acknowledgements and citing

**Licensing**
Please find a copy of the GNU General Public License v3 ​in the repository.

**Acknowledgments**

Dr Pawel Paszek (University of Manchester) - supervisor of the MSc research project in
which MSERTrack was developed.

Dr James Bagnall (University of Manchester) - developed an earlier version of this program,
‘FastTrack’, which inspired the approach. Also provided advice and ideas to the project.

Laurence Falconer (University of Bristol) - advice programming in MATLAB.


**Citing**
This program makes use of ​OME Bio-Formats​, a community driven, open source project for
for reading and writing image data. Information on how to cite this can be found ​here​.

**Contact information**
Please let me know if you have any problems using the app. If your use of this program results in publication, citation or acknowledgement would be appreciated. Please contact for further information:
**lv13916 -at- bristol.ac.uk​ (University of Bristol)**


