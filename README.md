# Analysis_tool_for_CFZs_array
This tool is for measuring CFZ area from a scanned image and the selected area was filtered by the scope from simulation result.  
The example image can be found in "A More Biomimetic Cell Migration Assay with High Reliability and its Applications." 

To install the tools, save the file Analysis_tool_for_CFZs_array.ijm under plugins\Scripts\Plugins in your Fiji installation. And you can find the tool in the Plugins menu in Fiji.

The procedure is simple. You only need to input the scanned image and simulation result, and the tool can automatically analyze and output the screened cell-free area results.

There are two custom parameters(variance filter radius and tophat radius), which are required to input before processing images. To determine these two paramters, a tuning process is necessary. The user-friendly tool "ID3_parameter_tuning.ijm" is to coded to assist the tuning process. You can directly use it on a sample image after installation.
