if (isOpen("") == false) {
	newImage("", "8-bit black", 256, 256, 0);
	run("Set Scale...", "distance=15.4321 known=1 unit=micron");
}
roiManager("deselect");
nameArray = newArray();
areaArray = newArray();
for (r=0; r<roiManager("count"); r++) {
	roiManager("deselect");
	roiManager("select", r);
	roiName = Roi.getName;
	nameArray = Array.concat(nameArray, roiName);
	roiManager("measure");
	area = Table.get("Area", 0);
	areaArray = Array.concat(areaArray, area);
	run("Clear Results");
}
roiManager("deselect");
Table.create("areas");
Table.setColumn("name", nameArray);
Table.setColumn("area", areaArray);

close("Results");

for (i=0; i<areaArray.length; i++) {
	cent = roiManager("select", i);
	cent = roiManager("index");
	roiManager("deselect");
	rab = roiManager("select", i+1);
	rab = roiManager("index");
	roiManager("deselect");
	frm = roiManager("select", i+2);
	frm = roiManager("index");
	roiManager("deselect");
	
	indexes = newArray(cent,rab);
	cORr = OrGate(indexes);
	cANDr = AndGate(indexes);
	selectWindow("areas");
	Table.set("cORr", i, cORr);
	Table.set("cORr", i+1, cORr);
	Table.set("cORr", i+2, cORr);
	Table.set("cANDr", i, cANDr);
	Table.set("cANDr", i+1, cANDr);
	Table.set("cANDr", i+2, cANDr);
	
	indexes = newArray(rab,frm);
	rORf = OrGate(indexes);
	rANDf = AndGate(indexes);
	selectWindow("areas");
	Table.set("rORf", i, rORf);
	Table.set("rANDf", i, rANDf);
	Table.set("rORf", i+1, rORf);
	Table.set("rANDf", i+1, rANDf);
	Table.set("rORf", i+2, rORf);
	Table.set("rANDf", i+2, rANDf);
	
	indexes = newArray(cent,frm);
	cORf = OrGate(indexes);
	cANDf = AndGate(indexes);
	selectWindow("areas");
	Table.set("cORf", i, cORf);
	Table.set("cANDf", i, cANDf);
	Table.set("cORf", i+1, cORf);
	Table.set("cANDf", i+1, cANDf);
	Table.set("cORf", i+2, cORf);
	Table.set("cANDf", i+2, cANDf);
	
	indexes = newArray(cent,rab,frm);
	cORrORf = OrGate(indexes);
	cANDrANDf = AndGate(indexes);
	selectWindow("areas");
	Table.set("cORrORf", i, cORrORf);
	Table.set("cANDrANDf", i, cANDrANDf);
	Table.set("cORrORf", i+1, cORrORf);
	Table.set("cANDrANDf", i+1, cANDrANDf);
	Table.set("cORrORf", i+2, cORrORf);
	Table.set("cANDrANDf", i+2, cANDrANDf);
	
	Table.update;
	i = i+2;	
}


function AndGate(indexes) {
	roiManager("select", indexes);
	roiManager("and");
	if (selectionType() == -1) {
		makeRectangle(0, 0, 256, 256);
	}
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("measure");
	roiManager("delete");
	selectWindow("Results");
	result = Table.get("Area", 0);
	run("Clear Results");
	return result;
}
function OrGate(indexes) {
	roiManager("select", indexes);
	roiManager("combine");
	if (selectionType() == -1) {
		makeRectangle(0, 0, 256, 256);
	}
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("measure");
	roiManager("delete");
	selectWindow("Results");
	result = Table.get("Area", 0);
	run("Clear Results");
	return result;
}
