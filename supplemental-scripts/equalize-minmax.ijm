list = getList("image.titles");

Table.create("minmax");
og_run = 1;
for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
	if (og_run == 1) {
		getMinAndMax(min, max);
		Table.set("img", i, list[i]);
		Table.set("ogmin", i, min);
		Table.set("ogmax", i, max);
	}
	resetMinAndMax();
	getStatistics(area, mean, min, max, std, histogram);
	Table.set("img", i, list[i]);
	Table.set("min", i, min);
	Table.set("max", i, max);
	Table.update;
}

minArray = Table.getColumn("min");
maxArray = Table.getColumn("max");

minStats = Array.getStatistics(minArray, minI, max, mean, stdDev);
maxStats = Array.getStatistics(maxArray, min, max, maxI, stdDev);

for (i=0; i<list.length; i++) {
	selectWindow(list[i]);
	setMinAndMax(minI, maxI);
}
run("Tile");
