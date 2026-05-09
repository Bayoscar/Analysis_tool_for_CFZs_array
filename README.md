# Analysis_tool_for_CFZs_array（ATCA）
This tool is for measuring CFZ area from a scanned image and the selected area was filtered by the scope from simulation result. ATCA has two gridding modes: manual and automatic. Both procedure are simple. You only need to input the scanned image and simulation result, and the tool can automatically analyze and output the screened cell-free area results.

The example image can be found in "A More Biomimetic Cell Migration Assay with High Reliability and its Applications."

There are two custom parameters(variance filter radius and tophat radius), which are required to input before processing images. To determine these two paramters, a tuning process is necessary. The user-friendly tool "ID3_parameter_tuning.ijm" is to coded to assist the tuning process. You can directly use it on a sample image after installation.
### 1. Manual gridding
Rapid grid partitioning of microarray images is achieved by precompiling the array structure. The operation needs to be run in the ImageJ software and implemented via analysis_tool_for_CFZs_array.ijm.
To install the tools, save the file Analysis_tool_for_CFZs_array.ijm under plugins\Scripts\Plugins in your Fiji installation. And you can find the tool in the Plugins menu in Fiji.
### 2. Automatic gridding
Automatic gridding is realized through shock filter and mathematical morphology algorithms, which runs on MATLAB, and the main program is located in the PDE folder.
MATLAB R2016 or higher version is required. Part of the functions of ImageJ are also invoked during program operation, so it is necessary to install imageJ and the cross-platform protocol file MIJI. 
To install MIJI, please refer to:
https://imagej.net/plugins/miji
https://jp.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab

