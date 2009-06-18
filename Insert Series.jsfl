var serName = prompt("Enter the name of the series.\nUse % signs to indicate a number field.");
var start = prompt("Which number do you wish to start from?","1");
var end = prompt("Which number do you wish to end on?");
//var xloc = prompt("X location:","0");
//var yloc = prompt("Y location:","0");

//convert to number
start *= 1;
end *= 1;
xloc *= 1;
yloc *= 1;

var pos = serName.indexOf("%");
var bufLen;
for(bufLen=pos;bufLen<serName.length && serName.charAt(bufLen) == "%";bufLen++){

}
bufLen -= pos;



for(var i=start;i<=end;i++){

var numStr = i;
numStr += "";
while(numStr.length < bufLen){
numStr = "0" + numStr;
}
var item = serName.substr(0,pos) + numStr + serName.substr(pos+bufLen,serName.length -(pos+bufLen));

fl.getDocumentDOM().getTimeline().convertToBlankKeyframes();
fl.getDocumentDOM().library.selectItem(item);
fl.getDocumentDOM().library.addItemToDocument({x:0, y:0});
fl.getDocumentDOM().selectAll();
fl.getDocumentDOM().align('left', true);
fl.getDocumentDOM().align('top', true);



}