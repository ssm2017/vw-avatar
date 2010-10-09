// $Id: reg_key.lsl,v 1.3 2009/09/29 01:53:03 ssm2017binder Exp $
// @version SlUser
// @package CheckUser
// @copyright Copyright wene / ssm2017 Binder (C) 2009. All rights reserved.
// @license http://www.gnu.org/copyleft/gpl.html GNU/GPL, see LICENSE.php
// SlUser is free software and parts of it may contain or be derived from the GNU General Public License
// or other free or open source software licenses.

// **********************
//              STRINGS
// **********************
// === common ===
string _RESET = "Reset";
string _CLOSE = "Close";
string _MENU_TIMEOUT = "Menu time-out. Please try again.";
// === user ===
string _CHECKING_THE_REGKEY = "Checking the reg key";
string _ENTER_YOUR_REG_CODE_PLEASE = "Enter your reg code please";
string _CHECK_KEY = "Check key";
// === params ===
string _PARSE_PARAMS_ERROR = "Parse params error in about module";
// === http ===
string _REQUEST_TIMED_OUT = "Request timed out";
string _FORBIDEN_ACCESS = "Forbiden access";
string _PAGE_NOT_FOUND = "Page not found";
string _INTERNET_EXPLODED = "the internet exploded!!";
// ===================================================
//          NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ===================================================
// **********************
//          VARS
// **********************
string url = "";
string url2 = "";
string password = "";
integer display_info = 1;
integer update_speed = 30;
integer busy_time = 30;
key owner;
integer busy = FALSE;
key actual_user = NULL_KEY;
integer listener;
// separators
string HTTP_SEPARATOR = ";";
string PARAM_SEPARATOR = "||";
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
integer parseParams(string params) {
    // url | url2 | display_info | update_speed | busy_time | http_separator
    list values = llParseStringKeepNulls(params, [PARAM_SEPARATOR], []);
    url = llList2String(values, 0);
    url2 = llList2String(values, 1);
    password = llList2String(values, 2);
    display_info = llList2Integer(values, 3);
    update_speed = llList2Integer(values, 4);
    busy_time = llList2Integer(values, 5);
    HTTP_SEPARATOR = llList2String(values, 6);
    if (url != "" && url2 != "") {
        return TRUE;
    }
    return FALSE;
}
// **********************
//          HTTP
// **********************
// check reg key
key checkRegKeyId;
checkRegKey(key userKey, string regKey) {
    if (display_info) {
        llOwnerSay(_CHECKING_THE_REGKEY);
    }
    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    checkRegKeyId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=sluser"
                        +"&cmd=checkRegKey"
                        +"&output_type=message"
                        +"&arg="
                        // password
                        +"password="+md5pass+":"
                        +"keypass="+(string)keypass+":"
                        // user values
                        +"user_key="+ (string)userKey+":"
                        +"user_name="+ llKey2Name(userKey)+":"
                        +"reg_key="+ regKey);
}
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
            state getParams;
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
        llMessageLinked(LINK_THIS, ADD_APP, _CHECK_KEY, NULL_KEY);
        llMessageLinked(LINK_THIS, GET_PARAMS, "", NULL_KEY);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_PARAMS) {
            if (parseParams(str)) {
                state run;
            }
            else {
                llOwnerSay(_PARSE_PARAMS_ERROR);
            }
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
}
// **********************
//          RUN MODE
// **********************
state run {
    listen(integer channel, string name, key id, string message) {
        if (channel == 0) {
            llInstantMessage(id, _CHECKING_THE_REGKEY);
            llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
            llListenRemove(listener);
            actual_user = NULL_KEY;
            checkRegKey(id, message);
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_BUSY) {
            busy = TRUE;
            actual_user = id;
        }
        else if (num == SET_ENABLED) {
            llListenRemove(listener);
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
            else if (str == _CHECK_KEY) {
                llMessageLinked(LINK_THIS, SET_BUSY, "", actual_user);
                llInstantMessage(actual_user, _ENTER_YOUR_REG_CODE_PLEASE);
                listener = llListen(0, "", actual_user, "");
            }
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
    http_response(key request_id, integer status, list metadata, string body) {
      llOwnerSay(body);
        if (request_id != checkRegKeyId) {
            return;
        }
        if (status == 499) {
            llOwnerSay(_REQUEST_TIMED_OUT);
        }
        else if (status == 403) {
            llOwnerSay(_FORBIDEN_ACCESS);
        }
        else if (status == 404) {
            llOwnerSay(_PAGE_NOT_FOUND);
        }
        else if (status != 200 && status != 403 && status != 404) {
            llOwnerSay(_INTERNET_EXPLODED);
        }
        else {
            // get values
            body = llStringTrim(body , STRING_TRIM);
            list values = llParseStringKeepNulls(body, [HTTP_SEPARATOR], []);
            string answer = llList2String(values, 0);
            string message = llList2String(values, 1);
            string userKey = llList2String(values, 2);
            if (answer == "success") {
                llInstantMessage((key)userKey, message);
            }
            else if (answer == "error") {
                llInstantMessage((key)userKey, message);
            }
        }
    }
}
