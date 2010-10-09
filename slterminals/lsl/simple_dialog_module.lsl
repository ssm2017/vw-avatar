﻿// ********** SIMPLE DIALOG MODULE ********** //
// By Nargus Asturias
// Version 1.58
//
// Support only one dialog at a time. DO NOT request multiple dialog at once!
// Use of provided functions are recommented. Instruction here are for hardcore programmers only!
//
// Request: Send MessageLinked to the script. There are 3 dialog modes:
//      lnkDialog               : Normal dialog with message and buttons
//      lnkDialogNumericAdjust  : A dialog with buttons can be used to adjust numeric value
//      lnkDialogNotify         : Just a simple notification dialog. No return value and no buttons.
//
// Send MessageLinked with code lnkDialogReshow to force active dialog to reappear.
// Send MessageLinked with code lnkDialogCancel to force cancel active dialog
//
// If a lnkDialog is requested with more than 12 buttons, multi-pages dialog is used to show the buttons.
//
// [ For lnkDialog ]
// MessageLinked Format:
//      String part: List dumped into string, each entry seperated by '||'
//          Field 1:    Dialog message (512 bytes maximum)
//          Field 2:    Time-out data (integer)
//          Field 3-4:  Button#1 and return value pair
//          Field 5-6:  Button#2 and return value pair
//          And go on...
//      Key part: Key of AV who attend this dialog
//
// Response: MessageLinked to the prim that requested dialog (but no where else)
//      num == lnkDialogResponse:   AV click on a button. The buttons value returned as a string
//      num == lnkDialogTimeOut:    Dialog timeout.
//
// [ For lnkDialogNumericAdjust ]
// MessageLinked Format:
//      String part: List dumped into string, each entry seperated by '||'
//          Field 1:    Dialog message (512 bytes maximum)
//                          Put {VALUE} where you want the current value to be displayed)
//          Field 2:    Time-out data (integer)
//          Field 3:    Most significant value (ie. 100, for +/-100)
//          Field 4:    String-casted numeric value to be adjusted
//          Field 5:    2nd most significant value (ie. 10, for +/-10)
//          Field 6:    Use '1' to enable "+/-" button, '0' otherwise.
//          Field 7:    3nd significant value (ie. 1, for +/-1)
//          Field 8:    Use '1' for integer, or '0' for float
//          Field 9:    Least significant value (ie. 0.1, for +/-0.1)
//          Field 10:   Reserved. Not used.
//      Key part: Key of AV who attend this dialog
//
// Response: MessageLinked to the prim that requested dialog (but no where else)
//      num == lnkDialogResponse:   OK or Cancel button is clicked. The final value returned as string.
//      num == lnkDialogTimeOut:    Dialog timeout.
//
// ******************************************* //
 
// Constants
integer lnkDialog = 14001;
integer lnkDialogNumericAdjust = 14005;
integer lnkDialogNotify = 14004;
 
integer lnkDialogReshow = 14011;
integer lnkDialogCancel = 14012;
 
integer lnkDialogResponse = 14002;      // A button is hit, or OK is hit for lnkDialogNumericAdjust
integer lnkDialogCanceled = 14006;      // Cancel is hit for lnkDialogNumericAdjust
integer lnkDialogTimeOut = 14003;       // No button is hit, or Ignore is hit
 
string seperator = "||";
 
// Dialog variables
integer dialogChannel;      // Channel number used to spawn this dialog
string message;             // Message to be shown with the dialog
integer timerOut;           // Dialog time-out
key keyId;                  // Key of user who attending this dialog
integer requestedNum;       // Link-number of the requested prim
list buttons;               // List of dialog buttons
list returns;               // List of results from dialog buttons
 
float numericValue;
integer useInteger;
 
// Other variables
integer buttonsCount;
integer startItemNo;
integer listenId;
 
string redirectState;
 
integer responseInt = -1;
string responseStr;
key responseKey;
 
 
// ********** String Functions **********
string replaceString(string pattern, string replace, string source){
    integer index = llSubStringIndex(source, pattern);
    if(index < 0) return source;
 
    source = llDeleteSubString(source, index, (index + llStringLength(pattern) - 1));
    return llInsertString(source, index, replace);
}
 
// ********** Dialog Functions **********
// Function: createDialog
// Create dialog with given message and buttons, direct to user with give id
integer createDialog(key id, string message, list buttons){
    integer channel = -((integer)llFrand(8388608))*(255) - (integer)llFrand(8388608) - 11;
 
    llListenRemove(listenId);
    listenId = llListen(channel, "", keyId, "");
    llDialog(keyId, message, buttons, channel);
 
    return channel;
}
 
// Function: createMultiDialog
// Create dialog with multiple pages. Each page has Back, Next, and a Close button. Otherwise same functionality as createDialog() function.
integer createMultiDialog(key id, string message, list buttons, integer _startItemNo){
    integer channel = -llRound(llFrand( llFabs(llSin(llGetGMTclock())) * 1000000 )) - 11;
 
    if(_startItemNo < 0) _startItemNo = 0;
    if(_startItemNo >= buttonsCount - 1) _startItemNo -= 9;
    startItemNo = _startItemNo;
 
    integer vButtonsCount = buttonsCount - 2;
 
    // Generate list of buttons to be shown
    string closeButton = llList2String(buttons, buttonsCount - 1);
 
    integer stopItemNo = startItemNo + 8;
    if(stopItemNo >= buttonsCount - 1) stopItemNo = vButtonsCount;
 
    list thisButtons = llList2List(buttons, startItemNo, stopItemNo);
 
    // Generate dialog navigation buttons
    integer i = stopItemNo - startItemNo + 1;
    i = i % 3;
    if(i > 0) while(i < 3){
        thisButtons += [" "];
        ++i;
    }
 
    if(startItemNo > 0)
        thisButtons += ["<< BACK"];
    else thisButtons += [" "];
 
    thisButtons += [closeButton];
 
    if(stopItemNo < vButtonsCount)
        thisButtons += ["NEXT >>"];
    else thisButtons += [" "];
 
    // Append page number to the message
    integer pageNumber = (integer)(stopItemNo / 9) + 1;
    integer pagesCount = llCeil(vButtonsCount / 9.0);
    string vMessage = "PAGE: " + (string)pageNumber + " of " + (string)pagesCount + "\n" +
        message;
 
    // Display dialog
    llListenRemove(listenId);
    listenId = llListen(channel, "", keyId, "");
    llDialog(keyId, vMessage, thisButtons, channel);
 
    return channel;
}
 
// Function: generateNumericAdjustButtons
// Generate numeric adjustment dialog which adjustment values are in given list.
// If useNegative is TRUE, "+/-" button will be available.
list generateNumericAdjustButtons(list adjustValues, integer useNegative){
    list dialogControlButtons;
    list positiveButtons;
    list negativeButtons;
    list additionButtons;
 
    dialogControlButtons = ["OK", "Cancel"];
 
    // Config adjustment buttons
    integer count = llGetListLength(adjustValues);
    integer index;
    for(index = 0; (index < count) && (index < 3); index++){
        string sValue = llList2String(adjustValues, index);
 
        if((float)sValue != 0){
            positiveButtons += ["+" + sValue];
            negativeButtons += ["-" + sValue];
        }
    }
 
    // Check positive/negative button
    if(useNegative)
        additionButtons = ["+/-"];
    else additionButtons = [];
 
    // If there is fourth adjustment button
    if(count > 3){
        if(llGetListLength(additionButtons) == 0) additionButtons = [" "];
 
        string sValue = llList2String(adjustValues, index);
        additionButtons += ["+" + sValue, "-" + sValue];
    }else if(additionButtons != []) additionButtons += [" ", " "];
 
    // Return list dialog buttons
    return additionButtons + negativeButtons + positiveButtons + dialogControlButtons;
}
 
setResponse(integer int, string str, key id){
    responseInt = int;
    responseStr = str;
    responseKey = id;
}
 
checkDialogRequest(integer sender_num, integer num, string str, key id){
     if((num == lnkDialogNotify) || (num == lnkDialogNumericAdjust) || (num == lnkDialog)){
        list data = llParseString2List(str, [seperator], []);
 
        message = llList2String(data, 0);
        timerOut = llList2Integer(data, 1);
        keyId = id;
        requestedNum = sender_num;
        buttons = [];
        returns = [];
 
        if(timerOut > 7200) timerOut = 7200;
 
        integer i;
        integer count = llGetListLength(data);
        for(i=2; i<count;){
            buttons += [llList2String(data, i++)];
            returns += [llList2String(data, i++)];
        }
 
        buttonsCount = llGetListLength(buttons);
 
        if(num == lnkDialogNotify){
            dialogChannel = -((integer)llFrand(8388608))*(255) - (integer)llFrand(8388608) - 11;
            llDialog(keyId, message, buttons, dialogChannel);
            return;
        }else if(num == lnkDialogNumericAdjust)
            redirectState = "NumericAdjustDialog";
        else if(num == lnkDialog){
            if(buttonsCount > 12)
                redirectState = "MultiDialog";
            else redirectState = "Dialog";
        }
 
        state StartDialog;
    }
}
 
// ********** States **********
default{
    state_entry(){
        if(responseInt > 0) llMessageLinked(requestedNum, responseInt, responseStr, responseKey);
    }
 
    link_message(integer sender_num, integer num, string str, key id){
        checkDialogRequest(sender_num, num, str, id);
    }
}
 
state StartDialog{
    state_entry(){
        if(redirectState == "Dialog")                   state Dialog;
        else if(redirectState == "MultiDialog")         state MultiDialog;
        else if(redirectState == "NumericAdjustDialog") state NumericAdjustDialog;
        else state default;
    }
}
 
state Dialog{
    state_entry(){
        responseInt = -1;
        dialogChannel = createDialog(keyId, message, buttons);
        llSetTimerEvent(timerOut);
    }
 
    state_exit(){
        llSetTimerEvent(0);
    }
 
    on_rez(integer start_param){
        state default;
    }
 
    timer(){
        setResponse(lnkDialogTimeOut, "", keyId);
        //llMessageLinked(requestedNum, lnkDialogTimeOut, "", keyId);
        state default;
    }
 
    link_message(integer sender_num, integer num, string str, key id){
        if(num == lnkDialogReshow){
            dialogChannel = createDialog(keyId, message, buttons);
            llSetTimerEvent(timerOut);
        }else if(num == lnkDialogCancel) state default;
 
        else checkDialogRequest(sender_num, num, str, id);
    }
 
    listen(integer channel, string name, key id, string msg){
        if((channel != dialogChannel) || (id != keyId)) return;
 
        integer index = llListFindList(buttons, [msg]);
        setResponse(lnkDialogResponse, llList2String(returns, index), keyId);
        //llMessageLinked(requestedNum, lnkDialogResponse, llList2String(returns, index), keyId);
        state default;
    }
}
 
state MultiDialog {
    state_entry(){
        responseInt = -1;
        startItemNo = 0;
        dialogChannel = createMultiDialog(keyId, message, buttons, startItemNo);
        llSetTimerEvent(timerOut);
    }
 
    state_exit(){
        llSetTimerEvent(0);
    }
 
    on_rez(integer start_param){
        state default;
    }
 
    timer(){
        setResponse(lnkDialogTimeOut, "", keyId);
        state default;
    }
 
    link_message(integer sender_num, integer num, string str, key id){
        if(num == lnkDialogReshow){
            dialogChannel = createMultiDialog(keyId, message, buttons, startItemNo);
            llSetTimerEvent(timerOut);
        }else if(num == lnkDialogCancel) state default;
 
        else checkDialogRequest(sender_num, num, str, id);
    }
 
    listen(integer channel, string name, key id, string msg){
        if((channel != dialogChannel) || (id != keyId)) return;
 
        // Dialog control buttons
        if(msg == "<< BACK"){
            dialogChannel = createMultiDialog(keyId, message, buttons, startItemNo - 9);
            llSetTimerEvent(timerOut);
        }else if(msg == "NEXT >>"){
            dialogChannel = createMultiDialog(keyId, message, buttons, startItemNo + 9);
            llSetTimerEvent(timerOut);
        }else if(msg == " "){
            dialogChannel = createMultiDialog(keyId, message, buttons, startItemNo);
            llSetTimerEvent(timerOut);
 
        // Response buttons
        }else{
            integer index = llListFindList(buttons, [msg]);
            setResponse(lnkDialogResponse, llList2String(returns, index), keyId);
            //llMessageLinked(requestedNum, lnkDialogResponse, llList2String(returns, index), keyId);
            state default;
        }
    }
}
 
state NumericAdjustDialog {
    state_entry(){
        responseInt = -1;
 
        numericValue = llList2Float(returns, 0);
        useInteger = llList2Integer(returns, 2);
        buttons = generateNumericAdjustButtons(buttons, llList2Integer(returns, 1));
 
        string vMessage;
        if(useInteger)
            vMessage = replaceString("{VALUE}", (string)((integer)numericValue), message);
        else vMessage = replaceString("{VALUE}", (string)numericValue, message);
 
        dialogChannel = createDialog(keyId, vMessage, buttons);
        llSetTimerEvent(timerOut);
    }
 
    state_exit(){
        llSetTimerEvent(0);
    }
 
    on_rez(integer start_param){
        state default;
    }
 
    timer(){
        setResponse(lnkDialogTimeOut, "", keyId);
        //llMessageLinked(requestedNum, lnkDialogTimeOut, "", keyId);
        state default;
    }
 
    link_message(integer sender_num, integer num, string str, key id){
        if(num == lnkDialogReshow){
            dialogChannel = createDialog(keyId, message, buttons);
            llSetTimerEvent(timerOut);
        }else if(num == lnkDialogCancel) state default;
 
        else checkDialogRequest(sender_num, num, str, id);
    }
 
    listen(integer channel, string name, key id, string msg){
        if((channel != dialogChannel) || (id != keyId)) return;
 
        // Dialog control button is hit
        if(msg == "OK"){
            setResponse(lnkDialogResponse, (string)numericValue, keyId);
            //llMessageLinked(requestedNum, lnkDialogResponse, (string)numericValue, keyId);
            state default;
        }else if(msg == "Cancel"){
            setResponse(lnkDialogCanceled, (string)numericValue, keyId);
            llMessageLinked(requestedNum, lnkDialogCanceled, (string)numericValue, keyId);
            state default;
 
        // Value adjustment button is hit
        }else if(msg == "+/-")
            numericValue = -numericValue;
        else if(llSubStringIndex(msg, "+") == 0)
            numericValue += (float)llDeleteSubString(msg, 0, 0);
        else if(llSubStringIndex(msg, "-") == 0)
            numericValue -= (float)llDeleteSubString(msg, 0, 0);
 
        // Spawn another dialog if no OK nor Cancel is hit
        string vMessage;
        if(useInteger)
            vMessage = replaceString("{VALUE}", (string)((integer)numericValue), message);
        else vMessage = replaceString("{VALUE}", (string)numericValue, message);
        dialogChannel = createDialog(keyId, vMessage, buttons);
        llSetTimerEvent(timerOut);
   }
}
 