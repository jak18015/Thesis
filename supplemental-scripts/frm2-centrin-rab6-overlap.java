/*
Make binary multi-channel images of each channel
Create composite ROI's of overlap
Measure ROI areas
*/

wd = getDirectory("home") + "OneDrive - University of Connecticut/1-Projects/frm2/";
thresholdPath = wd + "results/.tif/gfp-centrin-rab6-overlaps/";
imagePath = wd + "data/";
tablePath = wd + "results/.csv/";
list = getFileList(imagePath);
regex = ".*gfp_centrin1_mapple-rab6.*";
table = "frm2-gfp_centrin1_mapple-rab6_overlap.csv";

if (isOpen(table) == false) {
	if (File.exists(tablePath + table) == false) {
		array = newArray();
		Table.create(table);
		Table.setColumn("img", array);
		Table.setColumn("channel", array);
		Table.setColumn("area", array);
	} else {
		open(tablePath + table);
	}
}

for (i=0; i<list.length; i++) {
	if (matches(list[i], regex) == false) {
		continue;
	}
	// open the image if not already open
	if (isOpen(list[i]) == false) {
		open(imagePath + list[i]);
	}
	rename(list[i]);
	// set to magenta, yellow, cyan
	SetChannelColors(list[i]);
	// create binary thresholded image
	selectWindow(list[i]);
	title = File.getNameWithoutExtension(getTitle());
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(channel, slice, frame);
	bin = MakeBinaryImage(list[i]);
	CreateRoiFromBinary(bin);
	CalculateOverlap(channels);
	MeasureRoiAreas(bin);
	AreaTable(table, channels, list[i]);
	close(list[i]);
	selectWindow(bin);
	save(thresholdPath + bin);
	close(bin);
	selectWindow(table);
	Table.save(tablePath + table);
}
exit;


function SetChannelColors(image) {
	selectWindow(image);
	Stack.setChannel(1);
	resetMinAndMax;
	run("Magenta");
	Stack.setChannel(2);
	resetMinAndMax;
	run("Cyan");
	Stack.setChannel(3);
	resetMinAndMax;
	run("Yellow");	
}
function MakeBinaryImage(image) {
	selectWindow(image);
	title = File.getNameWithoutExtension(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	mergeArg = newArray();
	for (c=1; c<=channels; c++) {
		selectWindow(image);
		run("Duplicate...", "duplicate channels="+c);
		dup = getTitle();
		run("Z Project...", "projection=[Max Intensity]");
		rename("C"+c);
		setAutoThreshold("MaxEntropy dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		close(dup);
		mergeArg = Array.concat(mergeArg, "c"+c+"="+"C"+c);
	}
	mergeArg = Array.concat(mergeArg, "create");
	mergeArg = String.join(mergeArg, " ");
	run("Merge Channels...", "" + mergeArg + "");
	rename(title + "-BIN.tif");
	bin = getTitle();
	SetChannelColors(bin);
	return bin;
}
function CreateRoiFromBinary(image) {
	selectWindow(image);
	title = File.getNameWithoutExtension(image);
	while (roiManager("count") != 0) {
		roiManager("select", 0);
		roiManager("delete");
	}
	for (c=1; c<=channels; c++) {
		selectWindow(image);
		Stack.setChannel(c);
		run("Create Selection");
		roiManager("add");
		roiManager("select", roiManager("count") -1);
		roiManager("rename", c);
	}
	roiManager("deselect");
	roiManager("combine");
	roiManager("add");
	if (roiManager("count") != 0) {
		roiManager("select", roiManager("count") -1);
		roiManager("rename", "combine");
		roiManager("deselect");
		selectWindow(image);
		run("Select None");
	}
}
function CalculateOverlap(channels) {
	comparisonArray = newArray();
	for (c=0; c<channels + 1; c++) {
		if (c < channels) {
			indexes = newArray(c, c+1);
		}
		if (c == channels-1) {
			indexes = newArray(c, 0);
		} 
		if (c == channels) {
			indexes = Array.getSequence(channels);
		} 
		indexesString = newArray();
		for (k = 0; k<indexes.length; k++) {
			indexesString[k] = indexes[k] + 1;
		}
		indexesString = String.join(indexesString, "-AND-");
		roiManager("select", indexes);
		roiManager("and");
		if (selectionType() != -1) {
			roiManager("add");
			roiManager("select", roiManager("count") -1);
			roiManager("rename", indexesString);				
		}
	}
}
function MeasureRoiAreas(image) {
	selectWindow(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	newImage("", "8-bit dark", width, height, slices);
	run("Set Scale...", "distance=15.4321 known=1 unit=micron");
	RoiManager.useNamesAsLabels(true);
	run("Set Measurements...", "area display redirect=  decimal=3");
	for (r=0; r<roiManager("count"); r++) {
		roiManager("select", r);
		roiManager("measure");
	}
	close("");
}
function AreaTable(table, channels, image) {
	selectWindow("Results");
	labelArray = Table.getColumn("Label");
	areaArray = Table.getColumn("Area");
	imageArray = Array.getSequence(labelArray.length);
	for (j=0; j<imageArray.length; j++) {
		imageArray[j] = image;
		array = split(labelArray[j], ":");
		labelArray[j] = String.join(array);
	}
	run("Clear Results");
	close("Results");
	selectWindow(table);
	rowIndex = Table.size;
	for (row = 0; row<imageArray.length; row++) {
		Table.set("img", rowIndex + row, imageArray[row]);
		Table.set("channel", rowIndex + row, labelArray[row]);
		Table.set("area", rowIndex + row, areaArray[row]);
	}
	Table.update;
}
