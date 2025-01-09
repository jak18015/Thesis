print("\\Clear");

overlapPath =
"C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/results/.tif/gfp-centrin-rab6-overlaps/";

overlapList = getFileList(overlapPath);
imageList = getList("image.titles");

for (i=0; i<imageList.length; i++) {
	SetChannelColors(imageList[i]);
}
wawa
for (i=0; i<imageList.length; i++) {
	imageTitle = File.getNameWithoutExtension(imageList[i]);
	for (l=0; l<overlapList.length; l++) {
		overlapTitle = File.getNameWithoutExtension(overlapList[l]);
		overlapTitle = split(overlapTitle, "_");
		overlapTitle = Array.deleteIndex(overlapTitle, overlapTitle.length-1);
		overlapTitle = String.join(overlapTitle, "_");
		if (matches(overlapTitle, imageTitle)) {
			open(overlapPath + overlapList[l]);
			getStatistics(area, mean, min, max, std, histogram);
			if (max == 0) {
				close();
				continue;
			}
			run("Create Selection");
			roiManager("add");
			roiManager("select", roiManager("count") - 1);
			roiManager("rename", File.getNameWithoutExtension(overlapList[l]));
			close(overlapList[l]);
		}
	}
}
roiManager("sort");


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