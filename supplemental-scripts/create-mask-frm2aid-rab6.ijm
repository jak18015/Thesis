wd = getDirectory("home") + "OneDrive - University of Connecticut/1-Projects/frm2/";
imgPath = wd + "data/";
maskPath = wd + "results/.tif/aid-rab6-masked/";
regex = ".*frm2-aid_mapple-rab6.*";

imgList = getFileList(imgPath);
imgList = TifFilter(imgList, regex);

maskList = getFileList(maskPath);
if (maskList.length > 0) {FilterAlreadyProcessedImages();}

list = imgList;

for (i=0; i<list.length; i++) {
	open(imgPath + list[i]);
	image = list[i];
	loop = true;
	idx = 0;
	while (loop == true) {
		MaskImage();
	}
}

function MaskImage() {
	selectWindow(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (c=1; c<=channels; c++) {
		Stack.setChannel(c);
		resetMinAndMax();
	}
	setTool(2);
	waitForUser("draw rab6 compartment area");
	run("Fit Spline");
	run("Make Inverse");
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("rename", image);
	run("Clear");
	run("Select None");
	save(maskPath + File.getNameWithoutExtension(image) + "_"+idx+".tif");
	close();
	idx = idx + 1;
	loop = getBoolean("Mask again?");
}

function TifFilter(array, regex) {
/*
 * This function filters out any items in an array that
 * don't end in with the specified file extension.
 * (.tif)
 */
	new_array = newArray();
	for (file = 0; file<array.length; file++) {
		if ((matches(array[file], ".*.tif"))&&(matches(array[file], regex))) {
			new_array = Array.concat(new_array, array[file]);
		}
	}
	return new_array;
}

function FilterAlreadyProcessedImages() {
	temp = newArray();
	for (i=0; i<imgList.length; i++) {
		counter = maskList.length;
		for (m=0; m<maskList.length; m++) {
			if ((matches(imgList[i], maskList[m]) == false)
				&&
				(m == maskList.length-1)) {
					temp = Array.concat(temp, imgList[i]);
			}
		}
	}
	list = temp;
}
