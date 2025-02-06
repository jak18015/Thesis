/*
Creates a .csv table from a custom dialog window for quickly binning images by cell cycle
*/

wd = getDirectory("home") + "OneDrive - University of Connecticut/1-Projects/frm2/";
tablePath = wd + "results/.csv/";

table = "cell_cycle.csv";
TableCreator(table);

list = getList("image.titles");
startingIndex = StartAt(list);
run("Cascade");

for (i=startingIndex; i<list.length; i++) {
	selectWindow(list[i]);
	setLocation(screenWidth/2, screenHeight/2);
	cell_cycle = CellCycle();
	selectWindow(table);
	row = getValue("results.count");
	Table.set("img", row, list[i]);
	Table.set("cell_cycle", row, cell_cycle);
	Table.update();
}
selectWindow(table);
Table.save(tablePath + table);

exit();

function StartAt(list) {
/*
 * StartAt() let's you "start at" a specific image
 * in the array, rather than always starting
 * at the beginning.
 */
	Dialog.createNonBlocking("Start At...");
	Dialog.addChoice("image", list);
	Dialog.show();
	choice = Dialog.getChoice();
	for (index = 0; index<list.length; index++) {
		if (matches(list[index], choice)) {
			return index;
		}
	}
	print("Something went wrong, didn't find choice in the list...");
	exit();
}

function TableCreator(table) {
/*
 * This function looks for a table matching the table variable
 * at the tablePath.
 * If one exists, it is opened.
 * If one does not exist, a new table is created.
 */
	if (isOpen(table) == false) {
		if (File.exists(tablePath + table) == false) {
			array = newArray();
			Table.create(table);
			Table.setColumn("img", array);
			Table.setColumn("cell_cycle", array);
		} else {
			open(tablePath + table);
		}
	}	
}
function CellCycle() {
	Dialog.createNonBlocking("Cell Cycle");
	Dialog.addChoice("Interphase or Division", newArray("Interphase", "Division"), "Interphase");
	Dialog.show();
	choice = Dialog.getChoice();
	return choice;
}
