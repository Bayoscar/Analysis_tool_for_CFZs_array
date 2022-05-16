// Ask for input files
Dialog.create("Locate the input files");
	Dialog.addFile("Scanned image:", "")
	Dialog.addFile("Simulation result:", "")
Dialog.show();

// Pick up user input
ScanImg = Dialog.getString();
SimuRes = Dialog.getString();

// Create a new file for saving cropped images
imgFolder = File.getDirectory(ScanImg);
file_img = File.getNameWithoutExtension(ScanImg);
file_res = File.getNameWithoutExtension(SimuRes);
CFZsFile = "Cropped_CFZs_from_" + file_img +"_and_"+ file_res;
File.makeDirectory(imgFolder + CFZsFile);
outDir = imgFolder + CFZsFile + "/";

cropCFZ(ScanImg,outDir);
CFZIndex = getIndex(SimuRes,outDir);
processFolder(outDir,CFZIndex);
close("*");
close("RoI Manager");
close("Results");

// -------------------------------------Crop_rectangle_arrays---------------------------------------//
function cropCFZ(input,output){
	open(input);
	imgID = getImageID();
	// Ask for user to draw a rectangle, to define extents
	waitForUser("Draw a rectangle to cover all the CFZ");
	
	// Get the coordinates from rectangle
	getSelectionCoordinates(x,y);
	
	// Ask for number of rows and columns
	Dialog.create("Parameters");
		Dialog.addNumber("Number of Rows:", 4);
		Dialog.addNumber("Number of Columns:", 26);
	Dialog.show();
	
	// Pick up user input and check it in log
	nRow   = Dialog.getNumber();
	nCol   = Dialog.getNumber();
	
	// Get rectangle lenth and width
	recLenth = abs(x[2] - x[0]);
	recWidth = abs(y[2] - y[0]);
	
	// Set two counts and an order for ROI
	countRow = 0;
	countCol = 0;
	roiOrder = 1;
	setBatchMode(true);
	roiManager("Reset");
	//roiManager("show all with labels");
	
	// Make arrays of rectangle Roi
	for(countRow = 0; countRow<nRow; countRow++){
		if (countRow % 2 == 0){
			for (countCol = 0; countCol<nCol; countCol++){
				dotx = x[0] + countCol * recLenth / nCol;
				doty = y[0] + countRow * recWidth / nRow;
				makeRectangle(dotx, doty, recLenth / nCol, recWidth / nRow);
				Roi.setName(roiOrder);
				roiOrder++;
				roiManager("Add");
			}
		}
		else {
			for (countCol = 0; countCol<(nCol-1); countCol++){
				dotx = x[0] + (countCol + 0.5) * recLenth / nCol;
				doty = y[0] + countRow * recWidth / nRow;
				makeRectangle(dotx, doty, recLenth / nCol, recWidth / nRow);
				Roi.setName(roiOrder);
				roiOrder++;
				roiManager("Add");	
			}		
		}
	}
	roiManager("deselect");
	//roiManager("Show All");
	roiManager("Show All with labels");
	roiManager("UseNames", "true");
	outDir = output;
	// Show the result in the stack
	RoiManager.multiCrop(outDir, " show");
	
	// Get the details of the ROIs
	roiManager("List");
	NumberOfROis=roiManager("count");

	// Save images
	for (i = 0; i < NumberOfROis; i++) {
		// Get the ROI label or name in the result List
		ROIName=getResultString("Name", i, "Overlay Elements of CROPPED_ROI Manager");
		// Save the image one by one in the stack
		selectWindow("CROPPED_ROI Manager");
		setSlice(i+1);
		//run("Duplicate...", "title="+FileName+"_"+ROIName);
		run("Duplicate...", "title=" + ROIName);
		saveAs("png", outDir + ROIName);
		close();
	}
	roiManager("Save", outDir + "Rectangle_ROi.zip");
	close("Overlay Elements of CROPPED_ROI Manager");
	waitForUser("Please check the cropped result and click OK if it is acceptable");
	selectImage(imgID);
	close();
}


// -------------------------------------Analyze_interested_CFZ---------------------------------------//
function getIndex(input,output){
	setBatchMode(false);
	// Input and output
	open(input);
	outDir = output;
	res = circleSize();
	setBatchMode(true);
	// Make a copy
	run("Duplicate...","title=copy");
	
	// Set measurements and find circle
	run("Set Measurements...", "area standard perimeter redirect=None decimal=3");
	
	// Split chnanel and close the blue one
	run("Split Channels");
	close("copy (blue)");
	
	// Find all circles and return the coordinates
	list_a = findCircle(res[0],res[1]);
	
	// Clear the measurement
	run("Clear Results");
	roiManager("Reset");
	
	// Find circles in 10%(red) zone and return the coordinates
	list_b = findCFZ();
	
	// Clean up the interface
	close("Results");
	
	// Convert string to value in list 
	list_a = stringToValue(list_a);
	list_b = stringToValue(list_b);
	
	// Seperate the coordinates and sort them into different lists
	list_ax = Array.slice(list_a, 0, list_a.length/2);
	list_ay = Array.slice(list_a, list_a.length/2);
	list_bx = Array.slice(list_b, 0, list_b.length/2);
	list_by = Array.slice(list_b, list_b.length/2);
	
	// Set the position error and match two lists of circles  
	positionError = 5;
	indexList = matchIndex(list_ax, list_ay, list_bx, list_by, positionError);
	roiManager("reset");
	return indexList;
}

function circleSize(){
	// Measure the size of circle
	roiManager("Reset");
	
	// Ask for user to draw a line over the approximate diameter of a circle
	waitForUser("Draw a line over the approximate diameter of a circle");
	
	// Get the line and points
	getSelectionCoordinates(x,y);
	
	// Calculate the approximate area of the circle
	r       = sqrt(pow(x[0] - x[1],2) + pow(y[0] - y[1],2))/2;
	cirSize = PI * r * r;
	minSize = cirSize * 0.5;
	maxSize = cirSize * 1.5; 
	res = newArray(minSize, maxSize);
	return  res;
}

function findCircle(minSize,maxSize){
	selectWindow("copy (red)");
	run("Gaussian Blur...", "sigma=0.5");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	//run("Create Mask");
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " pixel circularity=0.9-1.00 display exclude add");
	roiManager("Save", outDir + "all_circles.zip");
	selectWindow("copy (red)");
	//roiManager("show all with labels");
	circlePosition = getXY("copy (red)");
	return circlePosition;
}

function findCFZ(){
	selectWindow("copy (green)");
	run("Gaussian Blur...", "sigma=0.5");
	//setOption("BlackBackground",false);
	setAutoThreshold("Default dark");
	//run("Threshold...");
	//setThreshold(82, 255);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-500 pixel circularity=0.9-1.00 display exclude add");
	roiManager("Save", outDir + "circles_in_red.zip");
	selectWindow("copy (green)");
	//roiManager("show all with labels");
	circlePosition = getXY("copy (green)");
	return circlePosition;
}

function getXY(windowName){
	// Get the number of ROIs
	roiManager("List");
	NumberOfROis=roiManager("count");
	xyA = newArray();
	
	// Substrate X and Y and save it in the array
	for (i = 0; i < NumberOfROis; i++) {
		ROIX = getResultString("X", i, "Overlay Elements of " + windowName);
		xyA = Array.concat(xyA , ROIX);
	}
	for (i = 0; i < NumberOfROis; i++) {
		ROIY = getResultString("Y", i, "Overlay Elements of " + windowName);
		xyA = Array.concat(xyA , ROIY);
	}
	close("Overlay Elements of " + windowName);
	return xyA;
}

function matchIndex(ax,ay,bx,by,error){
	error = 5;
	index = newArray();
	for (i = 0; i < ax.length; i++){
		for( j = 0; j < bx.length; j++){
			if ( (bx[j]-error) < ax[i] && ax[i] < (bx[j]+error) && (by[j]-error) < ay[i] && ay[i] < (by[j]+error)){
				index = Array.concat(index,i+1);
				break;
			}
		}
	}
	return index;
}


function stringToValue(a){
	b = newArray(1);
	for (i =0; i<a.length; i++){
		b[i] = parseInt(a[i]);
	}
	return b;
}


// -------------------------------------"CFZ indentification3" with batch mode---------------------------------------//

function processFolder(input,indexList) {
	setBatchMode(false);
	// Convert value in the indexList to string and append the suffix
	list = newArray();
	for (i=0; i < indexList.length; i++){
		trans = toString(indexList[i]);
		trans = trans + ".png";
		list = Array.concat(list,trans);
	}
	
	// Process images with specific name
	areas = newArray();
	fileNames = newArray();
	
	// Note: This is a direct operation based on the file name in indexList, not a search for files in the directory.
	for (i = 0; i < list.length; i++) {
			fileName = File.getNameWithoutExtension(list[i]);
			fileNames = Array.concat(fileNames,fileName);
			area = processFile(input, list[i]);
			areas = Array.concat(areas,area);
	}
	
	// Show and save the result
	Array.show("CFZ_and_its_area", fileNames, areas);
	saveAs("Results", input + "/All_Results.csv");
}

function processFile(input, file) {
	// Process image
	imgprocess(input,file);

	// Find the largest CFZ
	CFZArea = getArea(input,file);
	
	run("Clear Results");
	roiManager("Reset");
	return CFZArea;
}

function imgprocess(input,file){
	open(input + "/" + file);
	fileName = File.getNameWithoutExtension(file);
	run("Set Measurements...", "area redirect=None decimal=3");
	run("Duplicate...", " ");
	run("Enhance Contrast...", "saturated=0.35");
	run("Variance...", "radius=2");
	run("Top Hat...", "radius=4 light don't");
	run("8-bit");
	setAutoThreshold("Otsu");
	//run("Threshold...");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "display add");
	saveAs("png", input + fileName + "_mask");
	close();
}

function getArea(input,file){
	if (roiManager("count")>1)
	{
	   area_large = newArray(roiManager("count"));
	   for (i = 0; i<(roiManager("count")); i++)
	   {
	       roiManager("select", i);
	       getStatistics(area_large[i]);
	   }
	   largest = 0;
	   for (i = 0; i<(roiManager("count")); i++)
	   {
	       if (area_large[i]>largest)
	       {
	           largest = area_large[i];
	           large = i;
	       }
	   }
	   roiManager("select", large);
	}
	else
	{
	   roiManager("select", 0);
	   getStatistics(largest);
	}
	fileName = File.getNameWithoutExtension(file);
	roiManager("Save", input + fileName + "_roi.roi");
	close(file);
	return largest;
}
