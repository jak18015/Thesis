input = "~/data/images/";
csvDir = "~/results/csv/";
roiDir = "~/results/roi/";

// GET DATE
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
TimeString =""+year+"";     
if (month < 10) {TimeString = TimeString+"0";}
    TimeString = TimeString+(month+1); 
if (dayOfMonth<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+dayOfMonth;

// create list of non-deconvolved images
list0 = getFileList(input);
var list = newArray();
for (i=0; i < list0.length; i++){
    if (endsWith(list0[i], "R3D.tif")) {
        list = Array.concat(list, list0[i]);
    }
}

Dialog.create("Image start");
Dialog.addChoice("image to start at", list);
Dialog.show();
initImg = Dialog.getChoice();

var initImgIndex = 0;

for (i=0; i < list.length; i++){
    if (list[i] == initImg){
        initImgIndex = i;
    }else{
        continue;
    }
}
    
// PROCESSING PIPELINE
for (i=initImgIndex; i < list.length; i++) { // open image
    if (isOpen(list[i]) == false) {
        open(input + list[i]);
        Stack.getDimensions(width, height, channels, slices, frames);
        if (frames < 151){
            print(list[i] + " has less than 151 frames and has been closed");
            close(list[i]);
        }
        if (frames > 151){
            print(list[i] + " has more than 151 and has been closed");
            close(list[i]);
        }
    }
    
    setLocation(300, screenHeight*0.01, 1000, 1000);
    Stack.setFrame(1);
    run("Animation Options...", "speed=10 first=1 last=100");
    doCommand("Start Animation");
    run("Select None");
    
    Dialog.createNonBlocking("How many parasites to scan?");
    Dialog.setLocation(screenWidth*0.01,screenHeight*0.01);
    Dialog.addMessage("Enter zero if you want to skip this image.");
    Dialog.addNumber("Parasite number: ", 2);
    Dialog.show();
    pCount = Dialog.getNumber();

    doCommand("Stop Animation");

    if (pCount == 0) {
        print("Image " + list[i] + " was not scanned.");
        close(list[i]);
        continue;
    }
    
    selectWindow(list[i]);
    run("Z Project...", "projection=[Sum Slices]");
    sumProj = getTitle();
    setLocation(screenWidth-675, 200, 700, 700);
    
    for (p=0; p < pCount; p++) {
        selectWindow(list[i]);
        Stack.setFrame(1);
        updateDisplay();
        
        Dialog.createNonBlocking(list[i] + " ("+p+1+"/"+pCount+")");
        Dialog.setLocation(screenWidth*0.01,screenHeight*0.01);
        Dialog.setInsets(5, 50, 10);
        Dialog.addNumber("Starting Frame: ", 1);
        Dialog.setInsets(5, 50, 10);
        Dialog.addNumber("Ending Frame: ", 40);
        Dialog.show();
        f0 = Dialog.getNumber();
        f1 = Dialog.getNumber();

        selectWindow(list[i]);
        setTool(5);
        waitForUser("draw line");
        roiManager("add");
        roiManager("select", roiManager("count")-1);
        roiName = Roi.getName;
        roiManager("rename", list[i] + "-p-" + roiName);
        selectWindow(list[i]);
        roiManager("select", roiManager("count")-1);
        lineProfile = getProfile();
        
        titleArray = newArray();
        actinArray = newArray();
        f0Array = newArray();
        f1Array = newArray();
        
        pixelArray = Array.getSequence(lineProfile.length);
        for (px=0;px<pixelArray.length;px++){
            pixelArray[px] = pixelArray[px] + 1;
            titleArray[px] = list[i];
            actinArray[px] = p+1;
            f0Array[px] = f0;
            f1Array[px] = f1;
        }
        
        if (p>0){
            appendTitle = Table.getColumn("img");
            appendActin = Table.getColumn("actinCount");
            appendPixel = Table.getColumn("px");
            appendF0 = Table.getColumn("fStart");
            appendF1 = Table.getColumn("fEnd");
            
            titleArray = Array.concat(appendTitle, titleArray);
            actinArray = Array.concat(appendActin, actinArray);
            pixelArray = Array.concat(appendPixel, pixelArray);
            f0Array = Array.concat(appendF0, f0Array);
            f1Array = Array.concat(appendF1, f1Array);
        }
        // set ID columns into Results table
        Table.setColumn("img", titleArray);
        Table.setColumn("actinCount", actinArray);
        Table.setColumn("px", pixelArray);
        Table.setColumn("fStart", f0Array);
        Table.setColumn("fEnd", f1Array);
        
        selectWindow(list[i]);
        Stack.getDimensions(width, height, channels, slices, frames);
        
        // measure actin profiles and set into Results table
        for (frame=0;frame<frames;frame++){
            selectWindow(list[i]);
            Stack.setFrame(frame+1);
            lineProfile = getProfile();
            if (p==0){
                Table.setColumn(frame+1, lineProfile);
            }
            else {
                appendFrame = Table.getColumn(frame+1);
                lineProfile = Array.concat(appendFrame, lineProfile);
                Table.setColumn(frame+1, lineProfile);
            }
        }
        
        if (p+1 == pCount){
            selectWindow(list[i]);
            title = File.getNameWithoutExtension(getTitle());
            close(list[i]);
            setOption("WaitForCompletion", true);
            saveAs("Results", csvDir+title+".csv");
            roiManager("save", roiDir+title+".zip");
            run("Clear Results");
            close("Results");
            roiManager("deselect");
            roiManager("delete");
            close(sumProj);
        }
    }
}
