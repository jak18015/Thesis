image = getTitle();
StackBrightness(image);
Stack.setChannel(1);
run("Red");
Stack.setChannel(2);
run("Blue");
Stack.setChannel(3);
run("Green");
// stack brightness-contrast
function StackBrightness(image) {
	selectWindow(image);
	resetMinAndMax();
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Split Channels");
	channel_array = newArray();
	for (c=1; c<=channels; c++) {
		channel_image = "C"+c+"-"+image;
		channel_array = Array.concat(channel_array, "c"+c+"="+channel_image);
		selectWindow("C"+c+"-"+image);
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		setMinAndMax(min, 0.35*max);
	}
	arg = String.join(channel_array, " ");
	arg = arg + " create";
	run("Merge Channels...", arg);
}