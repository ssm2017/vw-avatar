// $Id: slreguser.lsl,v 1.4 2009/10/05 02:38:24 ssm2017binder Exp $
// @version SlUser
// @package RegUser
// @copyright Copyright wene / ssm2017 Binder (C) 2009. All rights reserved.
// @license http://www.gnu.org/copyleft/gpl.html GNU/GPL, see LICENSE.php
// SlUser is free software and parts of it may contain or be derived from the GNU General Public License
// or other free or open source software licenses.

// **********************
//              STRINGS
// **********************
// symbols
string _SYMBOL_RIGHT = "✔";
string _SYMBOL_WRONG = "✖";
string _SYMBOL_WARNING = "⚠";
string _SYMBOL_RESTART = "↺";
string _SYMBOL_HOR_BAR_1 = "⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌⚌";
string _SYMBOL_HOR_BAR_2 = "⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊⚊";
string _SYMBOL_ARROW = "⤷";
// === common ===
string _RESET = "Reset";
string _CLOSE = "Close";
string _MENU_TIMEOUT = "Menu time-out. Please try again.";
// === params ===
string _PARSE_PARAMS_ERROR = "Parse params error in about module";
// === user ===
string _REGISTER = "Register";
string _YOU_HAVE = "You have";
string _SECS_TO_DRAG_THE_NOTECARD = "seconds to drag the notecard.";
// === registration ===
string _CHECKING_REGISTRATION = "Checking registration";
string _REGISTERING_USER = "Registering user";
string _REGISTER_USER = "Reg user";
string _CHECK_VALUES_BEFORE_REGISTERING = "Check values before registering";
// === notecard ===
string _GET_REG_CARD = "Get reg card";
string _THE_NOTECARD_NAMED = "The notecard named";
string _IS_MISSING = "is missing for the user registration";
string _START_READING_CONFIG_NOTECARD = "Start reading notecard";
string _NOTECARD_IS_MISSING = "Notecard is missing";
string _CONFIG_NOTECARD_READ = "Config notecard read";
string _CHECK_USERNAME = "Check username";
string _CHECK_SL_USERNAME = "Check sl username";
string _CHECK_PASSWORD = "Check password";
string _CHECK_EMAIL = "Check email";
// http errors
string _REQUEST_TIMED_OUT = "Request timed out";
string _FORBIDDEN_ACCESS = "Forbidden access";
string _PAGE_NOT_FOUND = "Page not found";
string _INTERNET_EXPLODED = "the internet exploded!!";
string _SERVER_ERROR = "Server error";
// ===================================================
//          NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ===================================================
// **********************
//          VARS
// **********************
string reg_card_name = "register";
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
// notecard vars
list inventory = [];
integer start_notecard_count = 0;
integer iLine = 0;
key configNoteCard;
string notecard_name;
// menu
integer menu_listener;
integer menu_channel;
// user registration
string user_website_username;
string user_sl_username;
string user_password;
string user_email_address;
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
// parse parameters
integer parseParams(string params) {
    // url ; url2 ; display_info ; update_speed ; busy_time
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
// get inventory
getInventory() {
    integer num = llGetInventoryNumber(INVENTORY_ALL);
    integer i;
    for (i = 0; i < num; ++i) {
        inventory = (inventory=[]) + inventory + [llGetInventoryName(INVENTORY_ALL, i)];
    }
}
// clean inventory
cleanInventory() {
    integer num = llGetInventoryNumber(INVENTORY_ALL);
    string name;
    integer i;
    for (i = 0; i < num; ++i) {
        name = llGetInventoryName(INVENTORY_ALL, i);
        if (llListFindList(inventory, [name]) == -1) {
            llRemoveInventory(name);
        }
    }
}
// **********************
//          HTTP
// **********************
// register user
key checkRegistrationId;
checkRegistration() {
    llInstantMessage(actual_user, _CHECKING_REGISTRATION);
    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    checkRegistrationId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=slreguser"
                        +"&cmd=checkRegistration"
                        +"&output_type=message"
                        +"&arg="
                        // password
                        +"password="+md5pass+":"
                        +"keypass="+(string)keypass+":"
                        // user values
                        +"website_username="+user_website_username+":"
                        +"user_key="+(string)actual_user+":"
                        +"pass="+user_password+":"
                        +"email="+user_email_address);
}
// register save
key registerSaveId;
registerSave() {
    llInstantMessage(actual_user, _REGISTERING_USER);
    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    registerSaveId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=slreguser"
                        +"&cmd=fullRegister"
                        +"&output_type=message"
                        +"&arg="
                        // password
                        +"password="+md5pass+":"
                        +"keypass="+(string)keypass+":"
                        // user values
                        +"website_username="+user_website_username+":"
                        +"email="+user_email_address+":"
                        +"user_key="+(string)actual_user+":"
                        +"sl_username="+llKey2Name(actual_user)+":"
                        +"pass="+user_password);
}
// get server answer
getServerAnswer(integer status, string body) {
    if (status == 499) {
        llOwnerSay(_SYMBOL_WARNING+ " "+ (string)status+ " "+ _REQUEST_TIMED_OUT);
    }
    else if (status == 403) {
        llOwnerSay(_SYMBOL_WARNING+ " "+ (string)status+ " "+ _FORBIDDEN_ACCESS);
    }
    else if (status == 404) {
        llOwnerSay(_SYMBOL_WARNING+ " "+ (string)status+ " "+ _PAGE_NOT_FOUND);
    }
    else if (status == 500) {
        llOwnerSay(_SYMBOL_WARNING+ " "+ (string)status+ " "+ _SERVER_ERROR);
    }
    else if (status != 403 && status != 404 && status != 500) {
        llOwnerSay(_SYMBOL_WARNING+ " "+ (string)status+ " "+ _INTERNET_EXPLODED);
        llOwnerSay(body);
    }
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
        getInventory();
        start_notecard_count = llGetInventoryNumber(INVENTORY_NOTECARD);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_READY) {
            if (llGetInventoryType(reg_card_name) != INVENTORY_NONE) {
                state getParams;
            }
            else {
                llOwnerSay(_THE_NOTECARD_NAMED + " \"" + reg_card_name + "\" " + _IS_MISSING);
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
        llMessageLinked(LINK_THIS, ADD_APP, _REGISTER_USER, NULL_KEY);
        llMessageLinked(LINK_THIS, ADD_APP, _GET_REG_CARD, NULL_KEY);
        llMessageLinked(LINK_THIS, GET_PARAMS, "", NULL_KEY);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_PARAMS) {
            if (parseParams(str)) {
                state wait;
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
//          WAIT MODE
// **********************
state wait {
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_BUSY) {
            busy = TRUE;
            actual_user = id;
        }
        else if (num == SET_ENABLED) {
            llListenRemove(listener);
            busy = FALSE;
            actual_user = NULL_KEY;
            llAllowInventoryDrop(FALSE);
        }
        else if (num == SET_ACTUAL_USER) {
            actual_user = id;
        }
        else if (num == lnkDialogTimeOut) {
            dialogNotify(id, _MENU_TIMEOUT);
            state wait;
        }
        else if (num == lnkDialogResponse) {
            if (str == _RESET) {
                llResetScript();
            }
            else if (str == _GET_REG_CARD) {
                if (llGetInventoryType(reg_card_name) != INVENTORY_NONE) {
                    llGiveInventory(actual_user, reg_card_name);
                }
            }
            else if (str == _REGISTER_USER) {
                llMessageLinked(LINK_THIS, SET_BUSY, "", actual_user);
                llMessageLinked(LINK_THIS, ENABLE_COUNTDOWN, "TRUE", NULL_KEY);
                llInstantMessage(actual_user, _YOU_HAVE + " " + (string)busy_time + " " + _SECS_TO_DRAG_THE_NOTECARD);
                llAllowInventoryDrop(TRUE);
            }
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
    changed(integer mask) {
        if(mask & (CHANGED_ALLOWED_DROP | CHANGED_INVENTORY)) {
            integer act_notecard_count = llGetInventoryNumber(INVENTORY_NOTECARD);
            if (act_notecard_count > start_notecard_count) {
                notecard_name = llGetInventoryName(INVENTORY_NOTECARD, start_notecard_count);
            }
            if (llGetInventoryType(notecard_name) != INVENTORY_NONE) {
                llMessageLinked(LINK_THIS, ENABLE_COUNTDOWN, "FALSE", NULL_KEY);
                state checkNotecard;
            }
            else {
                llInstantMessage(actual_user, _NOTECARD_IS_MISSING);
            }
        }
    }
}
// *************************
//      READ THE NOTECARD
// *************************
state checkNotecard {
    on_rez(integer change) {
        llResetScript();
    }
    state_entry() {
        // read the notecard
        configNoteCard = llGetNotecardLine(notecard_name,iLine);
        llInstantMessage(actual_user, _START_READING_CONFIG_NOTECARD);
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
            state wait;
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
    dataserver(key queryId, string data) {
        if (queryId == configNoteCard) {
            if(data != EOF) {
                if (llGetSubString(data, 0, 1) != "//") {
                    if (data != "") {
                        list parsed = llParseString2List(data, [ "=" ], []);
                        string param = llToLower(llStringTrim(llList2String(parsed, 0), STRING_TRIM));
                        string value = llStringTrim(llList2String(parsed, 1), STRING_TRIM);
                        if (param != "") {
                            if (param == "username") {
                                user_website_username = value;
                            }
                            else if (param == "password") {
                                user_password = value;
                            }
                            else if (param == "email") {
                                user_email_address = value;
                            }
                        }
                    }
                }
                configNoteCard = llGetNotecardLine(notecard_name,++iLine);
            }
            else {
                llInstantMessage(actual_user, _CONFIG_NOTECARD_READ+" ...");
                // check values
                integer check = TRUE;
                if (user_website_username == "") {
                    llInstantMessage(actual_user, _CHECK_USERNAME);
                    check = FALSE;
                }
                if (user_password == "") {
                    llInstantMessage(actual_user, _CHECK_PASSWORD);
                    check = FALSE;
                }
                if (user_email_address == "") {
                    llInstantMessage(actual_user, _CHECK_EMAIL);
                    check = FALSE;
                }
                if (!check) {
                    llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
                    state wait;
                }
                else {
                    state register;
                }
            }
        }
    }
}
// ************************
//    CHECK REGISTRATION
// ************************
state register {
    on_rez(integer nbr) {
        llResetScript();
    }
    state_entry() {
        llRemoveInventory(notecard_name);
        checkRegistration();
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
            state wait;
        }
        else if (num == RESET) {
            llResetScript();
        }
        else if (num == lnkDialogTimeOut) {
            dialogNotify(id, _MENU_TIMEOUT);
            state wait;
        }
        else if (num == lnkDialogResponse) {
            if (str == _RESET) {
                llResetScript();
            }
            else if (str == _REGISTER_USER) {
                registerSave();
            }
        }
    }
    http_response(key request_id, integer status, list metadata, string body) {
        if (request_id != checkRegistrationId && request_id != registerSaveId) {
            return;
        }
        if (status != 200) {
            getServerAnswer(status, body);
        }
        else {
            body = llStringTrim(body , STRING_TRIM);
            list values = llParseStringKeepNulls(body,[HTTP_SEPARATOR],[]);
            string answer = llList2String(values, 0);
            string value = llList2String(values, 1);
            if (request_id == checkRegistrationId) {
                if (answer == "success") {
                    llInstantMessage(actual_user, value);
                    dialog(actual_user, _CHECK_VALUES_BEFORE_REGISTERING+"\n username = "+user_website_username+"\n password = "+user_password+"\n email = "+user_email_address, [_REGISTER_USER], [_REGISTER_USER]);
                }
                else if (answer == "registration closed" || answer == "already registered" || answer == "error") {
                    llInstantMessage(actual_user, value);
                    llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
                    state wait;
                }
            }
            else if (request_id == registerSaveId) {
                if (answer == "error" || answer == "success need activate" || answer == "success reg complete") {
                    llInstantMessage(actual_user, value);
                    llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
                    state wait;
                }
            }
        }
    }
}