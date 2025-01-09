wd = "C:/Users/jak-w/OneDrive - University of Connecticut/1-Projects/frm2/";
centrin = wd + "results/.tif/gfp-centrin-zprojections/";
rab = wd + "results/.tif/gfp-centrin-zprojections/";

list = getFileList(centrin);
table = "centrin-overlap.csv";
Table.create(table);

for (i=0; i<list.length; i++) {
	open(centrin + list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (c=1; c<=channels; c++) {
		Stack.setChannel(c);
		resetMinAndMax;
	}
	value = Diag();
	if (value[1] == "skip") {
		close(list[i]);
		continue;
	}
	selectWindow(table);
	rowIndex = getValue("results.count");
	Table.set("img", rowIndex, list[i]);
	Table.set("cycle", rowIndex, value[0]);
	Table.set("overlapped", rowIndex, value[1]);
	Table.update;
	close(list[i]);
}

function Diag() {
	Dialog.createNonBlocking("");
	items = newArray("Interphase", "Puncta Formation", "Centrosome Duplication", "Early Daughters", "Late Daughters");
	Dialog.addChoice("Cell Cycle", items);
	Dialog.addCheckbox("overlapped?", 1);
	Dialog.addCheckbox("skip?", 0);
	Dialog.show();
	item = Dialog.getChoice();
	checkbox = Dialog.getCheckbox();
	skip = Dialog.getCheckbox();
	if (skip == 1) {
		return newArray(item, "skip");
	} else {
		return newArray(item, checkbox);
	}
}
