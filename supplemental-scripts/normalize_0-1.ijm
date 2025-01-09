// remove rb crosstalk
image = getTitle();
normalized_image = ImageNormalization(image);

function ImageNormalization(image) {
	setBatchMode("hide");
	selectWindow(image);
	bit = bitDepth() 
	if (bit == 16) {
		type = "16-bit";
		min_x = 0;
		max_x = 65535;
	} else {
		exit("error; bit depth");
	}
	Stack.getDimensions(width, height, channels, slices, frames);
	newImage("norm_"+image, "32-bit", width, height, slices);
	norm_image = getTitle();
	for (x=0; x<width; x++0) {
		for (y=0; y<height; y++) {
			for (z=1; z<=slices; z++) {
				Normalize();
			}
		}
	}
	function Normalize() {
		selectWindow(image);
		setSlice(z);
		px = getPixel(x, y);
		px = (px - min_x) / (max_x - min_x);
		selectWindow(norm_image);
		setSlice(z);
		setPixel(x, y, px);		
	}
	selectWindow(norm_image);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	setMinAndMax(min, max);
	setBatchMode("exit and display");
	return norm_image;
}

//	selectWindow(image);
//	resetMinAndMax();
//	getMinAndMax(min, max);
//	scalar = min/max;
//	print("\\Clear");
//	print(min);
//	print(max);