// $Id: terminal.lsl,v 1.12 2010/04/19 21:57:33 ssm2017binder Exp $
// @version SlUser
// @package Terminal
// @copyright Copyright wene / ssm2017 Binder (C) 2009. All rights reserved.
// @license http://www.gnu.org/copyleft/gpl.html GNU/GPL, see LICENSE.php
// SlUser is free software and parts of it may contain or be derived from the GNU General Public License
// or other free or open source software licenses.

// **********************
//      USER PREFS
// **********************
// url ex: string url = "http://test.com";
string url = "";
// password
string password = "0000";
// grid name
string grid_login_uri = "https://login.agni.lindenlab.com/cgi-bin/login.cgi";
// infos
integer display_info = 1;
// update speed
integer update_speed = 0;
// busy time
integer busy_time = 30;
// **********************
//  DRUPAL VERSION URL
// **********************
string url2 = "/secondlife";
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
string _CHOOSE_AN_OPTION = "Choose an option";
string _SCRIPT_WILL_STOP = "The script will stop";
string _ENTERING_WAIT_MODE = "Entering wait mode";
string _SENDING_A_LOG_MESSAGE = "Sending a log message";
// === user ===
string _ENABLE = "Enable";
string _ONLY_ONE_USER_AT_A_TIME = "Only one user can use the terminal at a time";
string _ONLY_ONE_REQUEST_AT_A_TIME = "Only one request can be done at a time";
// === terminal ===
string _NO_URL = "Something went wrong, no url. ";
string _TERMINAL_INIT = "Terminal initialisation";
string _ENABLING_THE_TERMINAL = "Registering the terminal";
string _UPDATING_THE_TERMINAL = "Updating the terminal";
// === terminal status ===
string _TERMINAL_IS_DISABLED = "Terminal is disabled";
string _TERMINAL_IS_ENABLED = "Terminal is enabled";
string _TERMINAL_IS_BUSY = "Terminal is busy";
// http errors
string _REQUEST_TIMED_OUT = "Request timed out";
string _FORBIDDEN_ACCESS = "Forbidden access";
string _PAGE_NOT_FOUND = "Page not found";
string _INTERNET_EXPLODED = "the internet exploded!!";
string _SERVER_ERROR = "Server error";
string _METHOD_NOT_SUPPORTED = "Method unsupported";
// ===================================================
//          NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ===================================================
// **********************
//      VARS
// **********************
string token;
key owner;
string owner_name;
key rpc_channel;
string http_url;
integer update_time;
integer act_time;
integer countdown = FALSE;
// user
integer request_time;
integer busy = FALSE;
key actual_user = NULL_KEY;
// separators
string HTTP_SEPARATOR = ";";
string PARAM_SEPARATOR = "┆";
string ARGS_SEPARATOR = "|";
// **********************
//      CONSTANTS
// **********************
integer RESET = 20000;
integer ADD_APP = 20001;
integer ENABLE_COUNTDOWN = 20002;
integer LOG_MESSAGE = 70015;
// text display
integer SET_TEXT = 70101;
integer SET_TEXT_COLOR = 70102;
// status
integer SET_READY = 20011;
integer SET_ENABLED = 20012;
integer SET_DISABLED = 20013;
integer SET_BUSY = 20014;
integer GET_STATUS = 70010;
// params
integer SET_PARAMS = 20025;
integer GET_PARAMS = 20026;
// user
integer SET_ACTUAL_USER = 20101;
integer GET_ACTUAL_USER = 20102;
// money
integer GIVE_MONEY = 70081;
// ************************************
//      GIVE VALUES TO OTHER SCRIPT
// ************************************
giveParams() {
    // url | url2 | password | display_info | update_speed | busy_time | http_separator | args separator | token
    string params = url+PARAM_SEPARATOR // 0
                    +url2+PARAM_SEPARATOR // 1
                    +password+PARAM_SEPARATOR // 2
                    +(string)display_info+PARAM_SEPARATOR // 3
                    +(string)update_speed+PARAM_SEPARATOR // 4
                    +(string)busy_time+PARAM_SEPARATOR // 5
                    +HTTP_SEPARATOR+PARAM_SEPARATOR // 6
                    +ARGS_SEPARATOR+PARAM_SEPARATOR // 7
                    +token; // 8
    llMessageLinked(LINK_THIS, SET_PARAMS, params, NULL_KEY);
}
// **************************
//      SET MESSSAGE
// **************************
setMessage(integer status) {
    string message = "";
    vector color = <0.0, 1.0, 0.0>;
    if (status == SET_ENABLED) {
        busy = FALSE;
        message = _TERMINAL_IS_ENABLED;
        color = <0.0, 1.0, 0.0>;
    }
    else if (status == SET_DISABLED) {
        message = _TERMINAL_IS_DISABLED;
        color = <1.0, 0.0, 0.0>;
    }
    else if (status == SET_BUSY) {
        busy = TRUE;
        message = _TERMINAL_IS_BUSY;
        color = <1.0, 0.5, 0.0>;
    }
    llMessageLinked(LINK_SET, SET_TEXT_COLOR, (string)color, NULL_KEY);
    llMessageLinked(LINK_SET, SET_TEXT, message, NULL_KEY);
}
// **********************
//          HTTP
// **********************
key url_request;
// register terminal
key registerTerminalId;
registerTerminal() {
    if (display_info) {
        llOwnerSay(_ENABLING_THE_TERMINAL);
    }
    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    registerTerminalId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=slterminals"
                        +"&cmd=registerTerminal"
                        +"&output_type=message"
                        +"&args_separator="+ARGS_SEPARATOR
                        +"&arg="
                        // password
                        +"password="+ md5pass+ARGS_SEPARATOR
                        +"keypass="+ (string)keypass+ARGS_SEPARATOR
                        // terminal values
                        +"grid_login_uri="+llEscapeURL(grid_login_uri)+ARGS_SEPARATOR
                        +"sim_hostname="+ llGetSimulatorHostname());
}
// update terminal
key updateTerminalId;
updateTerminal() {
    if (display_info) {
        llOwnerSay(_UPDATING_THE_TERMINAL);
    }
    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    updateTerminalId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=slterminals"
                        +"&cmd=updateTerminal"
                        +"&output_type=message"
                        +"&args_separator="+ARGS_SEPARATOR
                        +"&arg="
                        // password
                        +"password="+ md5pass+ARGS_SEPARATOR
                        +"keypass="+ (string)keypass+ARGS_SEPARATOR
                        // terminal values
                        +"sim_hostname="+ llGetSimulatorHostname()+ARGS_SEPARATOR
                        +"grid_login_uri="+llEscapeURL(grid_login_uri)+ARGS_SEPARATOR
                        +"rpc_channel="+ (string)rpc_channel+ARGS_SEPARATOR
                        +"http_url="+ llStringToBase64(http_url));
}
// log message
key logMessageId;
logMessage(string str) {
    if (display_info) {
        llOwnerSay(_SENDING_A_LOG_MESSAGE);
    }
    // get the message
    list parsedMessage = llParseString2List(str,[PARAM_SEPARATOR],[]);
    string severity = llList2String(parsedMessage, 0);
    string message = llList2String(parsedMessage, 1);

    // build password
    integer keypass = (integer)llFrand(9999)+1;
    string md5pass = llMD5String(password, keypass);
    // send the request
    logMessageId = llHTTPRequest(url+url2, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        // common values
                        "app=slterminals"
                        +"&cmd=log"
                        +"&output_type=message"
                        +"&args_separator="+ARGS_SEPARATOR
                        +"&arg="
                        // password
                        +"password="+ md5pass+ARGS_SEPARATOR
                        +"keypass="+ (string)keypass+ARGS_SEPARATOR
                        +"token="+ llMD5String(token, keypass)+ARGS_SEPARATOR
                        // terminal values
                        +"message="+ message+ARGS_SEPARATOR
                        +"severity="+severity);
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
list parsePostData(string message) {
    list postData = [];         // The list with the data that was passed in.
    list parsedMessage = llParseString2List(message,["&"],[]);    // The key/value pairs parsed into one list.
    integer len = ~llGetListLength(parsedMessage);
 
    while(++len) {          
        string currentField = llList2String(parsedMessage, len); // Current key/value pair as a string.
 
        integer split = llSubStringIndex(currentField,"=");     // Find the "=" sign
        if(split == -1) { // There is only one field in this part of the message.
            postData += [llUnescapeURL(currentField),""];  
        } else {
            postData += [llUnescapeURL(llDeleteSubString(currentField,split,-1)), llUnescapeURL(llDeleteSubString(currentField,0,split))];
        }
    }
    // Return the strided list.
    return postData ;
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
//      CALL THE MENU
// **********************
list apps_menu = [];
callMainMenu(key dest, string question, list choice) {
    list menu;
    menu = apps_menu;
    if (llGetListLength(choice) > 0) {
        menu = choice;
    }
    if (dest == owner) {
        menu += [_RESET];
    }
    menu += [_CLOSE];
    dialog(dest, question+" : ", menu, menu);
}
// ************************
//    CHECK REGISTRATION
// ************************
default {
    on_rez(integer nbr) {
        llMessageLinked(LINK_THIS, RESET, "", NULL_KEY);
        llResetScript();
    }
    state_entry() {
        llOwnerSay(_TERMINAL_INIT);
        // setup vars
        owner = llGetOwner();
        owner_name = llKey2Name(owner);
        // set message
        setMessage(SET_DISABLED);
        actual_user = NULL_KEY;
        busy = FALSE;
        request_time = 0;
    }
    touch_start(integer total_number) {
        if (llDetectedKey(0) == owner) {
            dialog(owner, _CHOOSE_AN_OPTION, [_ENABLE, _RESET], [_ENABLE, _RESET]);
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == lnkDialogTimeOut) {
            dialogNotify(id, _MENU_TIMEOUT);
            state default;
        }
        else if (num == lnkDialogResponse) {
            if (str == _RESET) {
                llResetScript();
            }
            else if (str == _ENABLE) {
                registerTerminal();
            }
        }
    }
    http_request(key id, string method, string body)
    {
        if (method == "GET") {
            if (llGetHTTPHeader(id, "x-path-info") == "/get_status/") {
                llHTTPResponse(id,200,"disabled");
            }
        }
        else {
            llHTTPResponse(id,405, _METHOD_NOT_SUPPORTED);
        }
    }
    http_response(key request_id, integer status, list metadata, string body) {
        llOwnerSay(body);
        if (request_id != registerTerminalId) {
            return;
        }
        if (status != 200) {
            getServerAnswer(status, body);
        }
        else {
            // get the values
            body = llStringTrim(body , STRING_TRIM);
            list values = llParseStringKeepNulls(body,[HTTP_SEPARATOR],[]);
            string answer = llList2String(values, 0);
            string value = llList2String(values, 1);
            token = llList2String(values, 2);
            if (request_id == registerTerminalId) {
                if (answer == "success") {
                    llOwnerSay(value);
                    state wait;
                }
                else if (answer == "error") {
                    llOwnerSay(value);
                }
                else if (answer == "disable") {
                    llMessageLinked(LINK_THIS, RESET, "", NULL_KEY);
                    llResetScript();
                }
            }
        }
    }
    remote_data(integer type, key channel, key message_id, string sender, integer ival, string sval) {
        if (type & REMOTE_DATA_REQUEST) {
            string answer;
            if (ival == GET_STATUS) { // get status
                answer = "disabled";
            }
            llRemoteDataReply(channel, message_id, answer, 1);
        }
    }
}
// ************************
//            WAIT MODE
// ************************
state wait {
    on_rez(integer nbr) {
        llMessageLinked(LINK_THIS, RESET, "", NULL_KEY);
        llResetScript();
    }
    state_entry() {
        llOwnerSay(_ENTERING_WAIT_MODE);
        llMessageLinked(LINK_THIS, SET_READY, "", NULL_KEY);
        llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
        update_time = llGetUnixTime() + update_speed;
        llSetTimerEvent(1);
        // get addresses
        llOpenRemoteDataChannel();
        url_request = llRequestURL();
    }
    touch_start(integer total_number) {
        key toucher = llDetectedKey(0);
        if (busy && toucher != actual_user) {
            llInstantMessage(toucher, _ONLY_ONE_USER_AT_A_TIME);
        }
        else if (busy && toucher == actual_user) {
            llInstantMessage(toucher, _ONLY_ONE_REQUEST_AT_A_TIME);
        }
        else if (!busy || toucher == owner) {
            if (llGetListLength(apps_menu) > 0) {
                actual_user = toucher;
                llMessageLinked(LINK_THIS, SET_ACTUAL_USER, "", actual_user);
                callMainMenu(toucher, _CHOOSE_AN_OPTION, []);
            }
            else {
                if (toucher == owner) {
                    callMainMenu(toucher, _CHOOSE_AN_OPTION, []);
                }
            }
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == lnkDialogTimeOut) {
            dialogNotify(id, _MENU_TIMEOUT);
            state default;
        }
        else if (num == lnkDialogResponse) {
            if (str == _RESET) {
                llResetScript();
            }
        }
        else if (num == GET_PARAMS) {
            giveParams();
        }
        else if (num == SET_BUSY) {
            setMessage(SET_BUSY);
            actual_user = id;
            request_time = llGetUnixTime();
        }
        else if (num == SET_ENABLED) {
            setMessage(SET_ENABLED);
            actual_user = NULL_KEY;
            busy = FALSE;
            request_time = 0;
        }
        else if (num == ADD_APP) {
            apps_menu += [str];
        }
        else if (num == ENABLE_COUNTDOWN) {
            if (str == "TRUE") {
                countdown = TRUE;
            }
            else {
                countdown = FALSE;
            }
        }
        else if (num == LOG_MESSAGE) {
          logMessage(str);
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
    timer() {
        act_time = llGetUnixTime();
        if (countdown) {
            llInstantMessage(actual_user, (string)(busy_time - (act_time - request_time)));
        }
        if (busy && (act_time - request_time) >= busy_time) {
            llMessageLinked(LINK_THIS, SET_ENABLED, "", NULL_KEY);
            countdown = FALSE;
        }
        if (update_speed && act_time >= update_time) {
            update_time = act_time + update_speed;
            if (!busy) {
                llOpenRemoteDataChannel();
                url_request = llRequestURL();
            }
        }
    }
    http_request(key id, string method, string body) {
        list incomingMessage;
        if (method == URL_REQUEST_GRANTED) {
            http_url = body;
            updateTerminal();
        }
        else if (method == URL_REQUEST_DENIED) {
            llOwnerSay(_NO_URL + body);
        }
        else if (method == "GET") {
            if (llGetHTTPHeader(id, "x-path-info") == "/get_status/") {
                llHTTPResponse(id,200,"online");
            }
        }
        else if (method == "POST") {
            if (llGetHTTPHeader(id, "x-path-info") == "/withdraw/") {
                incomingMessage = parsePostData(body);
                // check for the password
                string md5pass = llMD5String(password, llList2Integer(incomingMessage, 3));
                if (md5pass != llList2String(incomingMessage, 1)) {
                  llHTTPResponse(id,200,"wrong password");
                }
                else {
                  llHTTPResponse(id,200,"sending request");
                  llMessageLinked(LINK_THIS, GIVE_MONEY, body, NULL_KEY);
                }
            }
        }
        else {
            llHTTPResponse(id,405, _METHOD_NOT_SUPPORTED);
        }
    }
    http_response(key request_id, integer status, list metadata, string body) {
        if (request_id != updateTerminalId) {
            return;
        }
        if (status != 200) {
            getServerAnswer(status, body);
        }
        else {
            // get the values
            body = llStringTrim(body , STRING_TRIM);
            list values = llParseStringKeepNulls(body,[HTTP_SEPARATOR],[]);
            string answer = llList2String(values, 0);
            string value = llList2String(values, 1);
            token = llList2String(values, 2);
            if (request_id == updateTerminalId) {
                if (answer == "success") {
                    llOwnerSay(value);
                    giveParams();
                    state wait;
                }
                else if (answer == "error") {
                    llOwnerSay(value);
                }
                else if (answer == "disable") {
                    llMessageLinked(LINK_THIS, RESET, "", NULL_KEY);
                    llResetScript();
                }
            }
        }
    }
    changed(integer c) {
        if (c & (CHANGED_REGION | CHANGED_REGION_START | CHANGED_TELEPORT) ) {
            llOpenRemoteDataChannel();
            url_request = llRequestURL();
        }
    }
    remote_data(integer type, key channel, key message_id, string sender, integer ival, string sval) {
        if (type & REMOTE_DATA_CHANNEL) {
            rpc_channel = channel;
            updateTerminal();
        }
        else if (type & REMOTE_DATA_REQUEST) {
            string answer;
            if (ival == GET_STATUS) { // get status
                answer = "online";
            }
            else if (ival == GIVE_MONEY) {
                llMessageLinked(LINK_THIS, GIVE_MONEY, sval, NULL_KEY);
                answer = "sending request";
            }
            llRemoteDataReply(channel, message_id, answer, 1);
        }
    }
}
