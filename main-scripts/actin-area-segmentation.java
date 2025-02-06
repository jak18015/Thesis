wd = //working directory
actinDir = wd + "cropped-img/";
maskDir = wd + "mask/img/";
actinList = getFileList(actinDir);
maskList = getFileList(maskDir);
thresholdSettings = "method=Bernsen radius=1 parameter_1=0 parameter_2=0 white stack";
output = wd + "segmentation/";
var indexChoice;

var uAct = newArray();
var uMask = newArray();

for (i=0; i<maskList.length; i++) {
    maskTitle = split(maskList[i], "_");
    maskTitle = Array.concat(maskTitle[0],maskTitle[1], maskTitle[2]);
    maskTitle = String.join(maskTitle, "-");
    for (j=0; j<actinList.length; j++) {
        actinTitle = split(actinList[j], "_");
        actinTitle = Array.concat(actinTitle[0],actinTitle[1],actinTitle[2]);
        actinTitle = String.join(actinTitle, "-");
        
        if (matches(maskTitle, actinTitle)) {
                uAct = Array.concat(uAct,actinList[j]);
                uMask = Array.concat(uMask,maskList[i]);
        }
    }
}

Indexer();


if (getBoolean("run in batch mode?") == true) {setBatchMode(true);}

for (img = indexChoice; img < uAct.length; img++) {

    open(maskDir + uMask[img]);
    vac = getTitle();
    open(actinDir + uAct[img]);
    actin = getTitle();
    Stack.getDimensions(width, height, channels, slices, frames);
    noExtTitle = File.getNameWithoutExtension(getTitle());
    areaAnalysis();
    path = output + "csv/" + noExtTitle + ".csv";
    selectWindow("Results");
    Table.save(path);
    if (File.exists(path)) {
        print("talbe success");
    }
    roiManager("save", output + "roi/" + noExtTitle + ".zip");
    path = output + "roi/" + noExtTitle + ".zip";
    if (File.exists(path)) {
        print("roi success");
        
    }
    close(actin);
    close(vac);
    run("Clear Results");
    roiManager("deselect");
    roiManager("delete");
}
exit();

function Indexer() {
    Dialog.create("Image start index");
    Dialog.addChoice("Start image analysis at: ", uMask, uMask[0]);
    Dialog.show();
    inputImageChoice = Dialog.getChoice();
    for (i=0; i < uMask.length; i++) {
        if (matches(inputImageChoice, uMask[i])) {
            indexChoice = i;
}}}

function areaAnalysis() {
    selectWindow(actin);
    noExtTitle = File.getNameWithoutExtension(actin);
    run("Subtract Background...", "rolling=25 stack");
    run("8-bit");
    run("Gaussian Blur...", "sigma=1 stack");
    resetMinAndMax;
    run("Auto Local Threshold", thresholdSettings);
    imageCalculator("Subtract stack", actin, vac);
    save(output + "img/" + actin);
    for (frame = 1; frame <= frames; frame++) {
        selectWindow(actin);
        Stack.setFrame(frame);
        run("Create Selection");
        if (selectionType() == -1) {
            print("ERROR: NO SELECTION"
            +"\nImage: " + actin
            +"\nFrame: " + frame
            +"\n__________\n");
            continue;
        }
        else {
            roiManager("add");
            runMacro("selectLastROI");
            roiManager("rename", noExtTitle+"-"+frame);
            run("Measure");
        }
        run("Select None");
    }
    actArray = Table.getColumn("Area");
    run("Clear Results");
    for (a=0; a < actArray.length; a++){
        Table.set("img", a, noExtTitle);
        Table.set("actArea", a, actArray[a]);
    }
}
