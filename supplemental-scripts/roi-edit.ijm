list = getList("image.titles");

for (i=0; i<list.length; i++) {
	if (matches(list[i], ".*BIN.*")) {
		list = Array.deleteValue(list, list[i]);
		i = -1;
		continue;
	}
}


for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
	title = File.getNameWithoutExtension(list[i]);
	title = split(title, "_");
	title = Array.deleteIndex(title, 0);
	title = String.join(title, "_");
	
	n = roiManager("count");
	for (roi = 0; roi < n; roi++) {
		roiManager("select", roi);
		roiName = Roi.getName;
		roidx = roiManager("index");
		if (matches(roiName, title + ".*")) {
			RoiEdit(roidx, list[i]);
		}	
	}
	roiManager("deselect");
	close(list[i]);
}
function RoiEdit(roidx, image) {
	waitForUser("editing this roi.");
	if (getBoolean("Skip this ROI?") == false) {
		continuous = true;
		while (continuous == true) {
			setTool(3);
			inv = getBoolean("remove or keep inside of freehand?", "remove", "keep");
			waitForUser("draw selection.");
			if (inv == true) {
				run("Make Inverse");
			}
			roiManager("add");
			roiManager("select", roiManager("count")-1);
			freehand = roiManager("index");
			indexes = newArray(roidx, freehand);
			roiManager("select", indexes);
			roiManager("and");
			roiManager("update");
			roiManager("deselect");
			roiManager("select", freehand);
			roiManager("delete");
			roiManager("deselect");
			roiManager("select", roidx);
			if (getBoolean("further edit this roi?") == false) {
				continuous = false;
			}
		}
		selectWindow(image);
		run("Select None");
		roiManager("deselect");
		roiManager("select", roidx);
	}
}
