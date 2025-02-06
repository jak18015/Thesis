/*
Creates a bounding box encompassing the rab6 compartment and crops a new image of that size
*/

wd = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/frm2-kd-on-rab6/";
data = wd + "data/";
results = wd + "results/rab6-compartment-crops/";

run("ROI Manager...");

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
	rename(image_list[file]);
	image = getTitle();
	x_image = File.getNameWithoutExtension(getTitle());

	projected_images = LayoutProjections(image);
	selectWindow(image);
	
	setTool("rectangle");
	while (roiManager("count") == 0) {
		waitForUser("Add ROI's to ROI manager");
		if (roiManager("count") == 0) {
			waitForUser("No ROI's added!");
		}
	}
	run("Select None");
	for (p=0; p<projected_images.length; p++) {
		selectWindow(projected_images[p]);
		close();
	}

	image_array = RoiCrop(image);
	RoiSave(results + "roi/" + x_image + ".zip");
	SaveImages(image_array, results + "img/");
	close(image);
}
exit;

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

function LayoutProjections(image) {
	menubar_width = 26;
	menubar_height = 56;
	scalar = 4;
	projection_array = newArray("[Max Intensity]", "[Sum Slices]", "Median");
	projected_images = newArray();
	for (p=0; p<projection_array.length; p++) {
		selectWindow(image);
		run("Z Project...", "projection="+projection_array[p]);
		projected_images = Array.concat(projected_images, getTitle());
	}
	selectWindow(image);
	run("Original Scale");
	Stack.getDimensions(width, height, channels, slices, frames);
	setLocation(10, 10, scalar*width+menubar_width, scalar*height+menubar_height);
	getLocationAndSize(main_x, main_y, main_width, main_height);
	subheight = scalar*height/3+menubar_height;
	subwidth = scalar*width + menubar_width;
	
	for (p=0; p<projected_images.length; p++) {
		selectWindow(projected_images[p]);
		setLocation(main_x+main_width, main_y+(subheight*p), subwidth, subheight);
	}
	return projected_images;
}

function RoiCrop(image) {
	selectWindow(image);
	image_array = newArray();
	for (roi=0; roi<roiManager("count"); roi++) {
		selectWindow(image);
		roi_image = x_image + "-" + roi+1 + ".tif";
		roiManager("select", roi);
		Roi.setProperty("img", roi_image);
		roiManager("update");
		run("Duplicate...", "duplicate");
		rename(roi_image);
		image_array = Array.concat(image_array, roi_image);
	}
	return image_array;
}

function RoiSave(path) {
	roiManager("deselect");
	roiManager("save", path);
	roiManager("delete");
}

function SaveImages(image_array, directory) {
	for (img = 0; img<image_array.length; img++) {
		selectWindow(image_array[img]);
		save(directory + image_array[img]);
		close();
	}
}