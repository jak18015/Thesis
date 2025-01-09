wd = "C:/Users/jak-w/OneDrive - University of Connecticut/1-Projects/frm2/";
data = wd + "data/";
centrin_out = wd + "results/.tif/gfp-centrin-zprojections/";
rab_out = wd + "results/.tif/gfp-centrin-zprojections/";

filelist = getFileList(data);
centrin_list = newArray();
rab_list = newArray();

setBatchMode(true);

for (i=0; i<filelist.length; i++) {
	if (matches(filelist[i], ".*frm2-gfp.*")) {
		if (matches(filelist[i], ".*centrin1.*")) {
			centrin_list = Array.concat(centrin_list, filelist[i]);
		}
		if (matches(filelist[i], ".*rab6.*")) {
			rab_list = Array.concat(rab_list, filelist[i]);
		}
	}
}

for (i=0; i<centrin_list.length; i++) {
	open(data + centrin_list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels > 1) {
		if (channels == 3) {
			channelColors = newArray("none", "Magenta", "Grays", "Green");	
		}
		if (channels == 2) {
			channelColors = newArray("none", "Magenta", "Green");
		}
		for (c=1; c<=channels; c++) {
			Stack.setChannel(c);
			run(channelColors[c]);
		}
	}
	run("Z Project...", "projection=[Max Intensity]");
	save(centrin_out + centrin_list[i]);
	close("*");
}
exit;
for (i=0; i<rab_list.length; i++) {
	open(data + rab_list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Z Project...", "projection=[Max Intensity]");
	save(rab_out + rab_list[i]);
	close("*");
}
