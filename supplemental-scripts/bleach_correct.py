"""
A fast bleach correction for testing, based on a recommendation by the creator
of the Histogram Matching method built into FIJI
"""

import ij
from ij import IJ, WindowManager
from ij.io import FileSaver
from ij.gui import GenericDialog, Roi, ProfilePlot
from ij.measure import CurveFitter
import os

def waitforuser(message=""):
	gd = GenericDialog("Wait for User")
	gd.addMessage(message)
	gd.showDialog()
	if gd.wasCanceled():
		exit()
	return True

def BleachCorrect(img_title):
	# Select the image window and get dimensions
	imp = WindowManager.getImage(img_title)
	width, height, channels, slices, frames = imp.getDimensions()	
	# Create a rectangle ROI over the entire image
	roi = Roi(0, 0, width, height)
	imp.setRoi(roi)
	# Get the Z-axis profile using ProfilePlot
	IJ.run(imp, "Plot Z-axis Profile", "")
	plot_window = WindowManager.getCurrentWindow() 
	plot = plot_window.getPlot()
	IJ.selectWindow(img_title + "-0-0")
	IJ.run("Close")
	xpoints = plot.getXValues() 
	ypoints = plot.getYValues()
	xpoints = [float(x) for x in xpoints]
	ypoints = [float(y) for y in ypoints]
	# Perform exponential fit
	fitter = CurveFitter(xpoints, ypoints)
	fitter.doFit(CurveFitter.EXP_WITH_OFFSET)
	c = fitter.getParams()[2]  # Get the background correction value
	# Perform bleach correction
	IJ.selectWindow(img_title)
	IJ.run(imp, "Bleach Correction", "correction=[Simple Ratio] background="+str(c))
	imp.changes = False
	imp.close()
	bc_img = IJ.getImage()
	bc_img.setTitle(img_title)
	IJ.log("\\Clear")
	# Close the original image and rename the duplicate
	IJ.run("Select None")
	return bc_img

# Run the main process
img = IJ.getImage().getTitle()
BleachCorrect(img)
