path = "C:/Users/jak-w/OneDrive - University of Connecticut/1-Projects/frm2/results/.tif/gfp-centrin-rab6-binary-merge/";

if (isOpen("") == false) {
	newImage("", "8-bit black", 256, 256, 0);
	run("Set Scale...", "distance=15.4321 known=1 unit=micron");
}

count = roiManager("count");


nameArray = newArray();

for (i=0; i<count; i++) {
	roiManager("select", i);
	roiName = Roi.getName;
	nameArray = Array.concat(nameArray, roiName);
}



baseArray = newArray();
for (i=0; i<nameArray.length; i++) {
	string = split(nameArray[i], "-");
	string = Array.deleteIndex(string, string.length-1);
	string = String.join(string, "-");
	baseArray = Array.concat(baseArray, string);
}
for (i=0; i<count; i++) {
	roiManager("select", i);
	c1 = Roi.getName;
	run("Create Mask");
	rename("c1");
	i++;
	selectWindow("");
	roiManager("select", i);
	c2 = Roi.getName;
	run("Create Mask");
	rename("c2");
	i++;
	selectWindow("");
	roiManager("select", i);
	c3 = Roi.getName;
	run("Create Mask");
	rename("c3");
	run("Merge Channels...", "c1=c1 c2=c2 c3=c3 create");
	rename(baseArray[i] + "-BIN.tif");
	Stack.setChannel(1);
	run("Magenta");
	Stack.setChannel(2);
	run("Cyan");
	Stack.setChannel(3);
	run("Yellow");
	save(path + baseArray[i] + "-BIN.tif");
	close();
}
