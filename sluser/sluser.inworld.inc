<?php
// $Id: sluser.inworld.inc,v 1.16 2010/06/18 21:00:07 ssm2017binder Exp $
/**
 * @package SlUser
 * @copyright Copyright (C) 2009 Wene / ssm2017 Binder (S.Massiaux). All rights reserved.
 * @license   GNU/GPL, http://www.gnu.org/licenses/gpl-2.0.html
 * SlUser is free software. This version may have been modified pursuant to the GNU General Public License,
 * and as distributed it includes or is derivative of works licensed under the GNU General Public License
 * or other free or open source software licenses.
 */

/**
* Route commands
*/
function sluser_inworld_controller($cmd, &$sl, $args) {
  $response = array();
  switch ($cmd) {

    case 'checkRegKey':
      $response = sluser_inworld_check_reg_key($sl, $args);
      break;
    case 'getRegKey':
      $response = sluser_inworld_get_reg_key($sl, $args);
      break;

    default:
      $response['status']   = FALSE;
      $response['message']  = t('Oops! Unknown command:'). $cmd;
      break;
  }
  $sl->response['status']   = $response['status'];
  $sl->response['message']  = $response['message']. ";". $args['user_key'];
}

/**
* Check the user's reg key
*/
function sluser_inworld_check_reg_key($sl, $args) {
  $response = array();
  $msg = '';

  // check the terminal password
  if (!slterminals_check_password($args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  $user_key = $args['user_key'];
  $user_name = $args['user_name'];
  $reg_key = $args['reg_key'];

  // check if the user is already registered
  $result = db_fetch_object(db_query("SELECT nid FROM {sluser} WHERE user_name = '%s' AND user_uuid = '%s'", $user_name, $user_key));
  if ($result->nid) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('You already have an account registered with this avatar.').';'.$user_key;
    return $response;
  }

  // get the avatar
  $result = db_fetch_object(db_query("SELECT nid FROM {sluser} WHERE reg_key = '%s'", $reg_key));
  if (!$result->nid) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong key.').';'.$user_key;
    return $response;
  }
  $avatar = node_load($result->nid);

  // get the grid values
  $result = db_fetch_object(db_query("SELECT grid_nid FROM {sluser_terminals} WHERE object_uuid = '%s'", $sl->objectkey));

  // add values to the avatar
  $avatar->grid_nid = $result->grid_nid;
  $avatar->title = $user_name;
  $avatar->user_name = $user_name;
  $avatar->user_uuid = $user_key;
  $avatar->validated = 1;
  node_save($avatar);
  $msg = t('Avatar saved');
/*
  $values = array();
  // change the role for the user
  $values['roles'] = $sluser->account->roles + array_filter(variable_get('sluser_global_settings_roles', array()));
  if (variable_get('sluser_global_settings_roles_replace', 0)) {
    $values['roles'] = array_filter(variable_get('sluser_global_settings_roles', array()));
  }

  // check for username replacement
  if (variable_get('sluser_global_settings_profile_force_username', 0) && ($user_name != $sluser->account->name)) {
    $values['name'] = $user_name;
    $msg = t("Your username on the web site does not match your avatar name. Your username has been changed and is now the same as your avatar's name. Please use this name to log into the web site.");
  }

  $account = new stdclass;
  $account->uid = $sluser->uid;
  $account = user_save($account, $values);
  if (!$account) {
    $response['status']   = FALSE;
    $response['message']  = "error;". t("Error saving user account.").';'. $user_key;
    return $response;
  }
*/
  $response['status']   = $registered['status'];
  $response['message']  = $registered['message']. ' '. $msg. ';'. $user_key;
  return $response;
}

/**
 *
 */
function sluser_inworld_get_reg_key($sl, $args) {
  $response = array();
  $msg = '';

  // check the terminal password
  if (!slterminals_check_password($args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  // get grid info
  $grid = slgrids_get_grid_by_terminal_uuid($sl->objectkey);

  // get some vars
  $msg = '';
  $params = array(
    'user_uuid' => $args['user_key'],
    'user_name' => $args['user_name'],
    'website_username' => $args['website_username'],
    'grid_nid' => $grid->nid
  );

  // check if there is already a pending regkey for this avatar
  $result = db_fetch_object(db_query("SELECT * FROM {sluser} WHERE user_uuid='%s' AND grid_nid=%d AND link_status = 0", $params['user_uuid'], $grid->nid));

  if ($result) {
    $msg .= t('You have a pending validation request on the website. Your validation key is : "!valkey" (without quotes and case sensitive)', array('!valkey' => $result->reg_key));
    $response['status'] = FALSE;
    $response['message'] = "error;". $msg;
    return $response;
  }

  // create a validation key
  $params['reg_key'] = module_invoke('user', 'password');
  $request = sluser_build_link_request($params);
  if ($request) {
    $msg .= t('You have a pending validation request on the website. Your validation key is : "!valkey" (without quotes and case sensitive)', array('!valkey' => $request->reg_key));
    $response['status'] = TRUE;
    $response['message'] = "success;". $msg;
  }
  else {
    $msg .= "\n". t('There was an error trying to create a request.');
    $msg .= "\n". t('Please try again later.');
    $response['message'] = "error;". $msg;
  }
  return $response;
}
