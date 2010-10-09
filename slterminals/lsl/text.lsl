// $Id: text.lsl,v 1.2 2009/10/05 19:21:41 ssm2017binder Exp $
// @version SlUser
// @package Text
// @copyright Copyright wene / ssm2017 Binder (C) 2009. All rights reserved.
// @license http://www.gnu.org/copyleft/gpl.html GNU/GPL, see LICENSE.php
// SlUser is free software and parts of it may contain or be derived from the GNU General Public License
// or other free or open source software licenses.

// constants
integer RESET = 20000;
integer SET_TEXT = 70101;
integer SET_TEXT_COLOR = 70102;
// vars
vector text_color = <1.,1.,1.>;
default {
    on_rez(integer number) {
        llResetScript();
    }
    state_entry() {
        llSetText("", <0,0,0>, 1);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SET_TEXT) {
            llSetText(str, text_color, 1);
        }
        else if (num == SET_TEXT_COLOR) {
            text_color = (vector)str;
        }
        else if (num == RESET) {
            llResetScript();
        }
    }
}