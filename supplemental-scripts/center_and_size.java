/*
Sizes and scales an active image window to the center of the monitor screen
*/

animate_bool = true;


list = getList("image.titles");

for (i = 0; i < list.length; i++) {
	
	selectWindow(list[i]);
	
	getMinAndMax(min, max);
	Stack.getDimensions(width, height, channels, slices, frames);
	
	size_scalar = 2;
	width_scaled = size_scalar*width;
	height_scaled = size_scalar*height;
	
	intensity_scalar = 0.8;
	max = intensity_scalar*max;
	
	if (channels > 1) {
		Stack.setChannel(1);
		run("Enhance Contrast", "saturated=0.4");
		Stack.setChannel(2);
		run("Enhance Contrast", "saturated=0.4");
	}
	else {
		run("Enhance Contrast", "saturated=0.4");
	}
	
	setLocation(0.5*screenWidth-0.5*width_scaled, 0.5*screenHeight-0.5*height_scaled, width_scaled, height_scaled);
	if (animate_bool == false) {
		doCommand("Stop Animation");
	}
	else {
		doCommand("Start Animation");
	}
}
