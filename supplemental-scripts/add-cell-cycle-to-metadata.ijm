wd = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/frm2-kd-on-rab6/";
data = wd + "data/";

filelist = getFileList(data);
image_list = newArray();

for (file=0; file<filelist.length; file++) {
	if (matches(filelist[file], ".*rab6.*")) {
		image_list = Array.concat(image_list, filelist[file]);
	}
}

idx = ImageSelection();
for (file=idx; file<image_list.length; file++) {
	open(data + image_list[file]);
	image = getTitle();
	run("Maximize");
	resetMinAndMax();
	getMinAndMax(min, max);
	setMinAndMax(min-0.1*max, max-0.5*max);
	doCommand("Start Animation");
	CellCycle(image);
	run("Stop Animation");
	save(data + image_list[file]);
	close("*");
}

function ImageSelection() {
	Dialog.createNonBlocking("Image Select...");
	Dialog.addChoice("img", image_list);
	Dialog.show();
	chosen_image = Dialog.getChoice();
	idx = 0;
	for (i=0; i<image_list.length; i++) {
		if (matches(image_list[i], chosen_image)) {
			idx = i;
			break;
		}
	}
	return idx;
}

function CellCycle(image) {
	selectWindow(image);
	Dialog.createNonBlocking("Cell cycle stage");
	Dialog.setLocation(3*screenWidth/4, screenHeight/4);
	Dialog.addCheckbox("Dividing?", 0);
	Dialog.addCheckbox("ignore this image?", 0);
	Dialog.show();
	cell_cycle_bool = Dialog.getCheckbox();
	ignore_bool = Dialog.getCheckbox();
	selectWindow(image);
	meta = getMetadata("Info");
	if (cell_cycle_bool == true) {
		setMetadata("Info", meta + "cellCycle: division\nignoreStatus: " + ignore_bool);
	}
	else {
		setMetadata("Info", meta + "cellCycle: interphase\nignoreStatus: " + ignore_bool);
	}
	
}
