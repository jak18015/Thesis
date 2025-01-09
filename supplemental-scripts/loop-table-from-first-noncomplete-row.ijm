print("\\Clear");

wd = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/";
csvPath = wd + "results/.csv/";
csvTitle = "frm2-aid_apicoplast-inheritance-quantification.csv";
if (isOpen(csvTitle) == false) {
	Table.open(csvPath + csvTitle);
}
tableSize = Table.size();

list = getList("image.titles");
startingRow = CheckTableIntegrity(csvTitle);
for (i=startingRow; i<list.length; i++) {
	selectWindow(list[i]);
	run("Maximize");
	setLocation(0,0);
	SetLuts(list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setSlice(round(slices/2));
	diagArray = CellStageAndDefectDialog(list[i]);
	Table.set("img", i, list[i]);
	Table.set("cellStage", i, diagArray[0]);
	Table.set("inheritanceDefect", i, diagArray[1]);
	Table.set("note", i, diagArray[2]);
	Table.update();
}
showMessage("Complete! \nDon't forget to save the table!");
exit;


function SetLuts(imageTitle) {
	/*
	 * Uses the predetermined lut arrays to color each channel of
	 * the active image.
	 */
	threeChannelColorLuts = newArray("Magenta", "Yellow", "Cyan");
	twoChannelColorLuts = newArray("Magenta", "Green");
	
	selectWindow(imageTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels == 2) {
		colorLuts = twoChannelColorLuts;
	} else {
		colorLuts = threeChannelColorLuts;
	}
	for (c=1; c<=channels; c++) {
		selectWindow(imageTitle);
		Stack.setChannel(c);
		Stack.setSlice(round(slices/2));
		resetMinAndMax();
		run(colorLuts[c-1]);
	}
}
function CheckTableIntegrity(tableTitle) {
	selectWindow(tableTitle);
	headers = Table.headings;
	headers = split(headers, "	");
	nanPostions = newArray();
	for (h=0; h<headers.length; h++) {
		array = Table.getColumn(headers[h]);
		for (a=0; a<array.length; a++) {
			if (matches(array[a], "NaN")) {
				nanPostions = Array.concat(nanPostions, a);
				print("NaN at position " + a + " in " + headers[h] + ", breaking...");
				break;
			}
			if (a == array.length - 1) {
				print("No NaN's in " + headers[h] + "!");
			}
		}
	}
	Array.getStatistics(nanPostions, min, max, mean, stdDev);
	startingRow = min;
	return startingRow;
}
function CellStageAndDefectDialog(imageTitle) {
	items = newArray("Interphase", "Elongation", "Daughter Formation", "NA");
	Dialog.createNonBlocking("Cell Stage and Defect Dialog");
	Dialog.setLocation(screenWidth - 400, 300);
	Dialog.addMessage("Image: " + imageTitle);
	Dialog.addMessage("\n");
	Dialog.addChoice("cell stage", items, items[0]);
	Dialog.addCheckbox("defect? (boolean)", false);
	Dialog.addString("note", "NA");
	Dialog.show();
	cellStage = Dialog.getChoice();
	booleanDefect = Dialog.getCheckbox();
	note = Dialog.getString();
	array = newArray(cellStage, booleanDefect, note);
	return array;
}
