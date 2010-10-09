<?php
// $Id: sluser.users.inc,v 1.14 2010/05/20 21:19:19 ssm2017binder Exp $
/**
 * @package SlUser
 * @copyright Copyright (C) 2009 Wene / ssm2017 Binder (S.Massiaux). All rights reserved.
 * @license   GNU/GPL, http://www.gnu.org/licenses/gpl-2.0.html
 * SlUser is free software. This version may have been modified pursuant to the GNU General Public License,
 * and as distributed it includes or is derivative of works licensed under the GNU General Public License
 * or other free or open source software licenses.
 */

/**
 * terminal settings form
 */
function slterminals_global_settings_form() {
  $form = array();

  $form['terminals'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Terminals'),
    '#collapsible'  => FALSE,
    '#collapsed'    => FALSE,
  );
  $form['terminals']['slterminals_global_settings_terminals_password'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Terminals password'),
    '#default_value'  => variable_get('slterminals_global_settings_terminals_password', "0000"),
    '#description'    => t('Define a password that the terminals will use to connect on the site.'),
  );
  $form['terminals']['slterminals_global_settings_defaut_terminal_uid'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Default terminal user'),
    '#default_value'  => variable_get('slterminals_global_settings_defaut_terminal_uid', "0"),
    //'#autocomplete_path' => 'user/autocomplete',
    '#description'    => t('Select a user uid to use when creating terminals. If empty, the uid will be 0 (anonymous).'),
  );
  return system_settings_form($form);
}
