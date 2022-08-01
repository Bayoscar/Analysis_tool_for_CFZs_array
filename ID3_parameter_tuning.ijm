// Process image
var varianceRadius = 4;
var topHatRadius = 6;
var TMode = true;
var largest = 0;
imgTitle = getTitle();

while (TMode) { // loop while tuning
	showDialog();
	imgprocess();
}

// --------- functions ----------

function showDialog() {
	Dialog.createNonBlocking("Set the parameters");
	Dialog.addSlider("Variance filter radius:", 1, 20, varianceRadius);
	Dialog.addSlider("Top Hat radius:", 1, 20, topHatRadius);
	Dialog.addCheckbox("Tuning mode", true);
	Dialog.show();
	varianceRadius = Dialog.getNumber();
	topHatRadius = Dialog.getNumber();
	TMode = Dialog.getCheckbox();
}

// Find the largest CFZ

function imgprocess() {
	selectWindow(imgTitle); // select the image to process
	getLocationAndSize(win_x, win_y, win_width, win_height); // get window pos and size
	run("Set Measurements...", "area redirect=None decimal=3");
	close("preview"); // close previous preview
	Roi.remove;
	roiManager("reset");
	run("Duplicate...", "title=new");
	setLocation(win_x + win_width, win_y, win_width, win_height); // move to the right of original image
	run("Enhance Contrast...", "saturated=0.35");
	run("Variance...", "radius=" + varianceRadius);
	run("Top Hat...", "radius=" + topHatRadius + " light don't");
	run("8-bit");
	setAutoThreshold("Otsu");
	//run("Threshold...");
	run("Convert to Mask");
	run("Fill Holes");
	rename("preview");
	run("Analyze Particles...", "display add");
	if (TMode) { // proceed if tuning
		close("Results");
		selectWindow(imgTitle);
		getArea();
	}
	if (!TMode) { // proceed if not tuning
		rename("result of " + imgTitle);
		selectWindow(imgTitle);
		getArea();
		print("The largest area is: " + largest);
	}
}

function getArea() {
	if (roiManager("count")>1) {
		area_large = newArray(roiManager("count"));
		for (i = 0; i<(roiManager("count")); i++) {
			roiManager("select", i);
			getStatistics(area_large[i]);
		}
		largest = 0;
		for (i = 0; i<(roiManager("count")); i++) {
			if (area_large[i]>largest) {
				largest = area_large[i];
				large = i;
			}
		}
		roiManager("select", large);
	}
	else {
		roiManager("select", 0);
		getStatistics(largest);
	}
}