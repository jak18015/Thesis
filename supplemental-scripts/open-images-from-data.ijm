directory = "C:/Users/jakek/OneDrive - University of Connecticut/1-Projects/frm2/data/";

dateRegex = ".*";
parasiteLine = "frm2-aid";
secondaryTag = "cpn60";
imgRegex = ".*" + parasiteLine + ".*" + secondaryTag + ".*";

OpenImagesFromData(directory, dateRegex, imgRegex);
exit;


function OpenImagesFromData(directory, dateRegex, imagingRegex) {
	dataList = getFileList(directory);
	for (d=0; d<dataList.length; d++) {
		if (matches(dataList[d], dateRegex)) {
			if (matches(dataList[d], imagingRegex)) {
				open(directory + dataList[d]);
			}
		}
	}
}