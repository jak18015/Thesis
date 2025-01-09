// Paths
wd = getDirectory("home")+"OneDrive - University of Connecticut/"+"1-Projects/frm2/";
imgPath = wd + "data/";
thresholdPath = wd + "results/.tif/aid-rab6-binary/";
tablePath = wd + "results/.csv/";
roiPath = wd + "results/.zip/";

// Image list
regex = ".*frm2-aid_mapple-rab6.*";
list = getFileList(imgPath);
list = TifFilter(list, regex);

// Output table
date = TodaysDate();
table = date + "_frm2-aid_mapple-rab6.csv";
TableCreator(table);
selectWindow(table);
Table.setLocationAndSize(screenWidth-500, 150, 500, 400);
tableImgs = Table.getColumn("img");

// Loop

startingIndex = StartAt(list, tableImgs);
for (i=startingIndex; i<list.length; i++) {
	// open image
	if (isOpen(list[i]) == false) {open(imgPath + list[i]);}
	rename(list[i]);
	image = list[i];
	run("Grays");
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.35");
	// extract info from name
	experiment = split(image, "_");
	experiment = experiment[0];
	parasiteNumber = getNumber("# of parasites", 2);
	if (parasiteNumber == 0) {
		close("*");
		continue;
	}
	if (matches(image, ".*minusiaa.*")) {
		treatment = "Control";
	} else {
		treatment = "FRM2-KD";
	}
	// create binary and roi
	imageBinary = MakeBinaryImage(image);
	while (roiManager("count") > 0) {
		roiManager("delete");
	}	
	roiArea = BinaryToRoi(imageBinary);
	//set to table
	selectWindow(table);
	row = getValue("results.count");
	Table.set("experiment", row, experiment);
	Table.set("img", row, image);
	Table.set("parasite_count", row, parasiteNumber);
	Table.set("treatment", row, treatment);
	Table.set("rab_area", row, roiArea);
	Table.update;
	// save table, binary, roi
	Table.save(tablePath + table);
	selectWindow(imageBinary);
	save(thresholdPath + imageBinary);
	roiManager("save", roiPath + File.getNameWithoutExtension(image) + ".zip");
	close("*");
	roiManager("delete");
}


function BinaryToRoi(imageBinary) {
	selectWindow(imageBinary);
	title = File.getNameWithoutExtension(imageBinary);
	run("Create Selection");
	type = selectionType();
	if (type==-1) {makeRectangle(0, 0, width, height);}
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("rename", title);
	selectWindow(imageBinary);
	roiManager("select", roiManager("count")-1);
	roiManager("measure");
	selectWindow("Results");
	roiArea = Table.get("Area", 0);
	run("Clear Results");
	close("Results");
	return roiArea;
}

function MakeBinaryImage(image) {
	selectWindow(image);
	title = File.getNameWithoutExtension(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	setLocation(screenWidth/2, screenHeight/2-500);
	run("Duplicate...", "frames=1");
	resetMinAndMax();
	reference = getTitle();		
	setLocation(screenWidth/2, screenHeight/2-200);
	run("Duplicate...", "frames=1");
	threshold = getTitle();
	setLocation(screenWidth/2, screenHeight/2+100);	
	run("Enhance Contrast...", "saturated=0.2");
	run("Gaussian Blur...", "sigma=1");
	run("Threshold...");
	Table.setLocationAndSize(screenWidth/2-300, screenHeight/2-100, 200, 200, "Threshold");
	waitForUser;
	run("Convert to Mask");
	rename(title + "-BIN.tif");
	bin = getTitle();
	close("Threshold");
	return bin;
}

function TifFilter(array, regex) {
	new_array = newArray();
	for (file = 0; file<array.length; file++) {
		if ( (matches(array[file], ".*.tif")) && (matches(array[file], regex)) ) {
			new_array = Array.concat(new_array, array[file]);
	}}
	return new_array;
}

function TodaysDate() {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	if (dayOfMonth < 10) {dayOfMonth = IJ.pad(dayOfMonth, 2);}
	day = dayOfMonth;
	month = month+1;
	formatted_date = String.join(newArray(year, month, day), "-");
	return formatted_date;
}

function TableCreator(table) {
	if (isOpen(table) == false) {
		if (File.exists(tablePath + table) == false) {
			array = newArray();
			Table.create(table);
			Table.setColumn("experiment", array);
			Table.setColumn("img", array);
			Table.setColumn("parasite_count", array);
			Table.setColumn("treatment", array);
			Table.setColumn("rab_area", array);
		} else {
			open(tablePath + table);
}}}

function StartAt(list, tableImgs) {
	if (tableImgs.length > 0) {
		lastEntry = tableImgs[tableImgs.length-1];
		for (idx=0; idx<list.length; idx++) {
			if (matches(list[idx], lastEntry)) {
				start = list[idx+1];
				break;
		}}
	} else {
		start = list[0];
	}
	Dialog.createNonBlocking("Start At...");
	Dialog.addChoice("image", list, start);
	Dialog.show();
	choice = Dialog.getChoice();
	for (index = 0; index<list.length; index++) {
		if (matches(list[index], choice)) {
			return index;
}}}
