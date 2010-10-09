// $Id: notecard_giver.lsl,v 1.3 2009/09/29 01:53:03 ssm2017binder Exp $
// @version SlUser
// @package GiveCard
// @copyright Copyright wene / ssm2017 Binder (C) 2009. All rights reserved.
// @license http://www.gnu.org/copyleft/gpl.html GNU/GPL, see LICENSE.php
// SlUser is free software and parts of it may contain or be derived from the GNU General Public License
// or other free or open source software licenses.

string notecard_name = "readme";
// **********************
//              STRINGS
// **********************
// === common ===
string _RESET = "Reset";
string _CLOSE = "Close";
string _MENU_TIMEOUT = "Menu time-out. Please try again.";
// === user ===
string _GET_NOTECARD = "Get Notecard";
string _THE_NOTECARD_NAMED = "The notecard named";
string _IS_MISSING = "is missing for the notecard giver";
// ===================================================
//          NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ===================================================
// **********************
//          VARS
// **********************
key owner;
integer busy = FALSE;
key actual_user = NULL_KEY;
// **********************
//          CONSTANTS
// **********************
integer RESET = 20000;
integer ADD_APP = 20001;
integer ENABLE_COUNTDOWN = 20002;
// status
integer SET_READY = 20011;
integer SET_ENABLED = 20012;
integer SET_DISABLED = 20013;
integer SET_BUSY = 20014;
// params
integer SET_PARAMS = 20025;
integer GET_PARAMS = 20026;
// user
integer SET_ACTUAL_USER = 20101;
integer GET_ACTUAL_USER = 20102;
// **********************
//          FUNCTIONS
// **********************
// ********** DIALOG FUNCTIONS **********
// Dialog constants
integer lnkDialog = 14001;
integer lnkDialogNotify = 14004;
integer lnkDialogResponse = 14002;
integer lnkDialogTimeOut = 14003;
integer lnkDialogReshow = 14011;
integer lnkDialogCancel = 14012;
string seperator = "||";
integer dialogTimeOut = 0;
string packDialogMessage(string message, list buttons, list returns){
    string packed_message = message + seperator + (string)dialogTimeOut;
    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++){
        string button = llList2String(buttons, i);
        if(llStringLength(button) > 24) button = llGetSubString(button, 0, 23);
        packed_message += seperator + button + seperator + llList2String(returns, i);
    }
    return packed_message;
}
dialogReshow(){llMessageLinked(LINK_THIS, lnkDialogReshow, "", NULL_KEY);}
dialogCancel(){
    llMessageLinked(LINK_THIS, lnkDialogCancel, "", NULL_KEY);
    llSleep(1);
}
dialog(key id, string message, list buttons, list returns){
    llMessageLinked(LINK_THIS, lnkDialog, packDialogMessage(message, buttons, returns), id);
}
dialogNotify(key id, string message){
    list rows;
    llMessageLinked(LINK_THIS, lnkDialogNotify,
        message + seperator + (string)dialogTimeOut + seperator,
        id);
}
// ********** END DIALOG FUNCTIONS **********
// **********************
//          MAIN ENTRY
// **********************
default {
    state_entry() {
        owner = llGetOwner();
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_READY) {
            if (llGetInventoryType(notecard_name) != INVENTORY_NONE) {
                state getParams;
            }
            else {
                llOwnerSay(_THE_NOTECARD_NAMED + " \"" + notecard_name + "\" " + _IS_MISSING);
            }
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
}
// **********************
//          GET PARAMS
// **********************
state getParams {
    state_entry() {
        llMessageLinked(LINK_THIS, ADD_APP, _GET_NOTECARD, NULL_KEY);
        state run;
    }
}
// **********************
//          RUN MODE
// **********************
state run {
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_BUSY) {
            busy = TRUE;
            actual_user = id;
        }
        else if (num == SET_ENABLED) {
            busy = FALSE;
            actual_user = NULL_KEY;
        }
        else if (num == SET_ACTUAL_USER) {
            actual_user = id;
        }
        else if (num == lnkDialogTimeOut) {
            dialogNotify(id, _MENU_TIMEOUT);
            state run;
        }
        else if (num == lnkDialogResponse) {
            if (str == _RESET) {
                llResetScript();
            }
            else if (str == _GET_NOTECARD) {
                if (llGetInventoryType(notecard_name) != INVENTORY_NONE) {
                    llGiveInventory(actual_user, notecard_name);
                }
            }
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
}