wd = getDirectory("home") + "OneDrive - University of Connecticut/1-Projects/frm2/";
imgPath = wd + "data/";
maskPath = wd + "results/.tif/gfp-centrin-rab6-masked/";
tablePath = wd + "results/.csv/";

table = "cell_cycle.csv";
Table.open(tablePath + table);
selectWindow(table);
cycleList = Table.getColumn("img");
close(table);
imgList = getFileList(imgPath);
maskList = getFileList(maskPath);

imgList = Array.sort(imgList);
cycleList = Array.sort(cycleList);
maskList = Array.sort(maskList);

temp = newArray();
for (c=0; c<cycleList.length; c++) {
	for (i=0; i<imgList.length; i++) {
		if (matches(imgList[i], cycleList[c])) {
			temp = Array.concat(
				temp, imgList[i]);
		}
	}
}
imgList = temp;
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
temp = newArray();

for (i=0; i<list.length; i++) {
	open(imgPath + list[i]);
	image = list[i];
	selectWindow(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (c=1; c<=channels; c++) {
		Stack.setChannel(c);
		resetMinAndMax();
	}
	setTool(2);
	waitForUser("draw parasite outline");
	run("Fit Spline");
	run("Make Inverse");
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("rename", image);
	run("Clear");
	run("Select None");
	save(maskPath + image);
	close();
}
