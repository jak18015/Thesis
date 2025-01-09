setBatchMode(true);

output_path = "D:/Jacob/1-projects/FRM2/all_frm2_images/";

selectWindow("filelist.csv");
filelist = Table.getColumn("path");

for (i=908; i<filelist.length; i++) {
	if (matches(filelist[i], ".*.dv|.*.nd2") == false) {continue;}
	if (matches(filelist[i], ".*STC.*|.*VOL.*|.*COR.*|.*PRJ.*")) {continue;}
	
	title = split(filelist[i], "/");
	for (items=0; items<title.length; items++) {
		print(title[items]);
		if (matches(title[items], ".*D:.*|.*Jacob.*|3-resources|microscopy|")) {
			title[items] = "__";
		}
	}
	title = Array.deleteValue(title, "__");
	title = String.join(title, "_");

	
	if (File.exists(output_path + title)) {continue;}
	else {
	open(filelist[i]);
	saveAs("tiff", output_path + title);
	close(filelist[i]);
	}
}
