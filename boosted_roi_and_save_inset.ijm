original_img = getTitle();
title = File.getNameWithoutExtension(getTitle());

Stack.getDimensions(width, height, channels, slices, frames);
if (slices > 1) {
	Stack.setSlice(round(slices/2));
}
if (channels > 1) {
	for (c=1; c<=channels; c++) {
		Stack.setChannel(c);
		resetMinAndMax();
	}
}
else {
	run("Enhance Contrast", "saturated=0.35");
}


img_dir = getDirectory("image");
dir = split(img_dir, File.separator);
dir = Array.deleteIndex(dir, dir.length-1);
dir = String.join(dir, "/") + "/";

runMacro("boosted_roi_create_with_custom_property", "150");
roi_title = Roi.getName;

run("Duplicate...", "duplicate");
dup_title = getTitle();
inset_title = title + "-" + roi_title;

inset_dir = dir + "insets/";
runMacro("make_directory", inset_dir);
save(inset_dir + inset_title + ".tif");

roi_dir = dir + "roi/";
runMacro("make_directory", roi_dir);
roiManager("save selected", dir + "roi/" + roi_title + ".roi");

roiManager("deselect");
roiManager("delete");
close("properties table");
close("*");
exit();
