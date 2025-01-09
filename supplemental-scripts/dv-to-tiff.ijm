indir = "C:/Users/jakek/OneDrive - University of Connecticut/3-Resources/microscopy/20240829_frm2-gfp_centrin_tubulin";
outdir = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/20240829_frm2-gfp_centrin-tubulin/data";
DvToTiff(indir, outdir);
// Convert all DV's in input_dir into TIFF's and save in output_dir 
function DvToTiff(input_dir, output_dir) {
	setBatchMode("hide");
	input_count = getFileList(input_dir);
	input_count = input_count.length;
	metrics = newArray("input filecount  = " + input_count);
	// change Windows-style file separators (if present) into UNIX-style with trailing slash
	input_dir = split(input_dir, File.separator);
	input_dir = String.join(input_dir, "/") + "/";
	output_dir = split(output_dir, File.separator);
	output_dir = String.join(output_dir, "/") + "/";
	// loop files
	filelist = getFileList(input_dir);
	dv_list = newArray();
	for (i=0; i<filelist.length; i++) {
		if (matches(filelist[i], ".*D.dv")) {
			dv_list = Array.concat(dv_list, filelist[i]);
		}
	}
	metrics = Array.concat(metrics, "" + dv_list.length + " .dv images");
	for (i=0; i<dv_list.length; i++) {
		open(input_dir + dv_list[i]);
		x_image = File.getNameWithoutExtension(getTitle());
		saveAs("tiff", output_dir + x_image + ".tif");
		close();
		if (i==0) {
			fontsize = 12;
			Dialog.createNonBlocking("Post-first file check");
			Dialog.addMessage(
				"The file \n\t" + input_dir + dv_list[i] + "\n"
				+ "was saved to:" + "\n"
				+ output_dir + x_image + ".tif", fontsize
			);
			Dialog.addMessage("Is this correct?", 2*fontsize);
			Dialog.addMessage("OK will continue with the rest of the files", fontsize);
			Dialog.addMessage("Cancel will exit the macro", fontsize);
			Dialog.show();
		}
	}
	output_count = getFileList(output_dir);
	output_count = output_count.length;
	metrics = Array.concat(metrics, "output filecount = " + dv_list.length);
	metrics = String.join(metrics, "\n");
	showMessage(metrics);
	setBatchMode("show");
}