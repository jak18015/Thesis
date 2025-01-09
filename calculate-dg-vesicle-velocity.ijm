trackmatePath = "C:/Users/jak-w/OneDrive - University of Connecticut/1-Projects/frm2/results/.csv/trackmate/";
UsersPath = "C:/Users/jak-w/Documents/";
img = getTitle();
title = File.getNameWithoutExtension(img);
BleachCorrect(img);
resetMinAndMax();
run("Enhance Contrast...", "saturated=[0.35]");
run("TrackMate");
waitForUser;
UsersList = getFileList(UsersPath);
for (i=0; i<UsersList.length; i++ ) {
	if (matches(UsersList[i], ".*tracks.csv")) {
		File.copy(UsersPath+UsersList[i], trackmatePath + title + "_tracks.csv");
		File.delete(UsersPath+UsersList[i]);
		break;
	}
}
if (File.exists(trackmatePath + title + "_tracks.csv")) {
	print(title + " moved.");
}
else {
	print("Couldn't find " + title + "_tracks.csv");
}

function BleachCorrect(img) {
	selectWindow(img);
	run("Grays");
	Stack.getDimensions(width, height, channels, slices, frames);
	title = getTitle();
	makeRectangle(0, 0, width, height);
	xpoints = newArray();
	ypoints = newArray();
	run("Plot Z-axis Profile");
	Plot.getValues(xpoints, ypoints);
	Fit.doFit(11, xpoints, ypoints);
	c = Fit.p(2);	
	close(title+"-0-0");
	selectWindow(title);
	run("Bleach Correction", "correction=[Simple Ratio] background="+c);
	dup = getTitle();
	close(title);
	selectWindow(dup);
	rename(title);
	run("Select None");
	close("Log");
}