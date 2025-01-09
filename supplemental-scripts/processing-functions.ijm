// Processing of FRM2 project related images
// paths
wd = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/";
dataDirectory = wd + "data/";
resultsDirectory = wd + "results/";
// used in ImagesFromDataFolder()
dateRegex = "2024-09-30";
imageRegex = "frm2-gfp_mapple-rab6";
// used in GetImageSubset()
imageSubsetCsv = imageRegex + "_image-subset.csv";
imageSubsetPath = resultsDirectory + ".csv/" + imageSubsetCsv;
subsetStatus = 0;
if (File.exists(imageSubsetPath)) {
	subsetArray = GetImageSubset(imageSubsetPath, imageSubsetCsv);
	subsetStatus = 1;
}
// used in SetLuts()
threeChannelColorLuts = newArray("Magenta", "Red", "Green");
twoChannelColorLuts = newArray("Magenta", "Green");

// batch mode for increased processing speed
//setBatchMode("hide");
// array of image filenames from data/ filtered using date and image regex
list = ImagesFromDataFolder(dataDirectory, dateRegex, imageRegex);

if (subsetStatus == 1) {
	list = subsetArray;
}
// main processing loop

for (i=0; i<list.length; i++) {
	open(dataDirectory + list[i]);
	rename(list[i]);
	if (matches(list[i], ".*frm2-gfp_mapple-rab6.*")) {
		print("match:");
		RemoveSingleChannel(list[i]);
	}
	FocusStackToMiddle(list[i]);
	SetLuts(list[i]);
	list[i] = ReplaceWithProjection(list[i]);
	rename(FormatImageWindowTitle(list[i]));
	list[i] = getTitle();
	Cropper(list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	channelArray = MoveChannelIdToEnd(list[i], channels);
	channelArray = Array.concat(channelArray, list[i]);
	for (j=0; j<channelArray.length; j++) {
		selectWindow(channelArray[j]);
		run("RGB Color");
		save(resultsDirectory + "z-projections/rgb/" + channelArray[j]);
		close(channelArray[j]);
	}
}
// exit batch mode, tile all processed images on the desktop, and exit the macro
setBatchMode("exit and display");
run("Tile");
exit;


function GetImageSubset(path, csv) {
	/*
	 * Checks for the presence of a csv file 
	 * containing a subset of images to use 
	 * instead of all images that match the regex.
	 */
	Table.open(path);
	array = Table.getColumn("img");
	close(csv);
	return array;
}

function ImagesFromDataFolder(directory, dateRegex, imagingRegex) {
	/*
	 * Uses the provided regexes and directory to construct
	 * an array of image filenames to loop over in the main processing loop.
	 */
	dataList = getFileList(directory);
	list = newArray();
	for (d=0; d<dataList.length; d++) {
		if (matches(dataList[d], ".*" + dateRegex + ".*")) {
			if (matches(dataList[d], ".*" + imagingRegex + ".*")) {
				list = Array.concat(list, dataList[d]);
			}
		}
	}
	return list;
}
function FocusStackToMiddle(imageTitle) {
	/*
	 * Places the slice focus at the most central slice,
	 * determined from the number of slices divided by 2,
	 * rounded to the nearest integer.
	 */
	selectWindow(imageTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setSlice(round(slices/2));
}
function SetLuts(imageTitle) {
	/*
	 * Uses the predetermined lut arrays to color each channel of
	 * the active image.
	 */
	selectWindow(imageTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels == 2) {
		colorLuts = twoChannelColorLuts;
	} else {
		colorLuts = threeChannelColorLuts;
	}
	for (c=1; c<=channels; c++) {
		selectWindow(imageTitle);
		Stack.setChannel(c);
		resetMinAndMax;
		run(colorLuts[c-1]);
	}
}
function ReplaceWithProjection(imageTitle) {
	/*
	 * Creates a projection of the image.
	 * The original image is closed and 
	 * the projection is returned in its place.
	 */
	projectionMethods = newArray(
		"Max Intensity", 
		"Min Intensity", 
		"Average Intensity", 
		"Sum Slices", 
		"Standard Deviation", 
		"Median"
		);
	selectWindow(imageTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	Dialog.createNonBlocking("Slices for projection");
	Dialog.addNumber("start", 1);
	Dialog.addNumber("stop", slices);
	Dialog.addChoice("method", projectionMethods);
	Dialog.show();
	start = Dialog.getNumber();
	stop = Dialog.getNumber();
	projectionMethod = Dialog.getChoice();
	run("Z Project...", "start="+start+" stop="+stop+" projection=["+projectionMethod+"]");
	projectedImage = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);
	for (c=1; c<=channels; c++) {
		Stack.setChannel(c);
		resetMinAndMax;
	}
	save(resultsDirectory + "z-projections/" + projectedImage);
	close(imageTitle);
	return projectedImage;
}
function FormatImageWindowTitle(imageTitle) {
	/*
	 * Removes non-informational filename items.
	 */
	imageTitle = split(imageTitle, "_");
	imageTitle = Array.deleteValue(imageTitle, "MAX");
	imageTitle = Array.deleteValue(imageTitle, "R3D-1");
	imageTitle = Array.deleteValue(imageTitle, "R3D");
	imageTitle = String.join(imageTitle, "_");
	return imageTitle;
}
function Cropper(imageTitle) {
	/*
	 * Interactive cropping of images to a default size of 150x150.
	 */
	selectWindow(imageTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	makeRectangle(width/2-75, height/2-75, 150, 150);
	waitForUser("place crop box");
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("save selected", resultsDirectory + ".roi/" + File.getNameWithoutExtension(imageTitle) + ".roi");
	run("Crop");
}
function MoveChannelIdToEnd(imageTitle, channelNumber) {
	/*
	 * Moves the default ImageJ assigned "C1-" channel prefixes to the end of the filename.
	 * Allows for files to be sorted by the original filename, rather than all channels from all
	 * images grouping together.
	 */
	channelArray = newArray();
	for (c=1; c<=channelNumber; c++) {
		selectWindow(imageTitle);
		run("Duplicate...", "title="+imageTitle+"-C"+c+".tif"+" duplicate channels="+c);
		channelTitle = getTitle();
		channelArray = Array.concat(channelArray, channelTitle);
	}
	return channelArray;
}
function RemoveSingleChannel(imageTitle) {
	/*
	 * Used in specific cases where a single channel should be removed.
	 * Reconstructs the merged image with the missing channel.
	 */
		selectWindow(imageTitle);
		run("Split Channels");
		run("Merge Channels...", "c1=C2-"+imageTitle+" c2=C3-"+imageTitle+ " create");
		rename(imageTitle);
		close("C1-"+imageTitle);
}