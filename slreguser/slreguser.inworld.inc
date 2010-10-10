<?php
// $Id: slreguser.inworld.inc,v 1.5 2009/10/05 02:38:24 ssm2017binder Exp $
/**
 * @package	SlUser
 * @subpackage SlRegUser
 * @copyright	Copyright (C) 2009 Wene / ssm2017 Binder (S.Massiaux). All rights reserved.
 * @license		GNU/GPL, http://www.gnu.org/licenses/gpl-2.0.html
 * SlUser is free software. This version may have been modified pursuant to the GNU General Public License,
 * and as distributed it includes or is derivative of works licensed under the GNU General Public License
 * or other free or open source software licenses.
 */

/**
* Route commands
*/
function slreguser_inworld_controller($cmd, &$sl, $args) {
  $response = array();
  switch ($cmd) {
    case 'checkRegistration':
      $response = slreguser_check_registration($sl, $args);
      break;

    case 'fullRegister':
      $response = slreguser_full_register($sl, $args);
      break;

    case 'quickRegister':
      $response = slreguser_quick_register($sl, $args);
      break;

    default:
      $response['status']   = FALSE;
      $response['message']  = t('Oops! Unknown command:'). $cmd;
      break;
  }
  $sl->response['status']   = $response['status'];
  $sl->response['message']  = $response['message'];
}

/**
* Check user registration
*/
function slreguser_check_registration(&$sl, $args) {
  $response = array();
$response['status']   = FALSE;
    $response['message']  = 'registration closed;'. t('Registration is closed.');
    return $response;
  // check the terminal password
  if (!module_invoke('sluser', 'terminal_check_password', $args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  // check if slreguser parameters allow registration
  if (variable_get('slreguser_global_settings_full_registration_enable', 1) == 0) {
    $response['status']   = FALSE;
    $response['message']  = 'registration closed;'. t('Registration is closed.');
    return $response;
  }

  // check if the user already have a sluser account
  $values = array(
    'uuid' =>$args['user_key']
  );
  $sluser = sluser_load($values);
  if ($sluser->id) {
    $account = user_load($sluser->uid);
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('You already have an account named "!name" on the site.', array('!name' => $account->name));
    return $response;
  }

  // check if the user name is already registered on the site
  $account = user_load(array('name' =>$args['website_username']));
  if ($account->uid != 0) {
    $response['status']   = FALSE;
    $response['message']  = 'already registered;'. t('User with this name is already registered.');
    return $response;
  }

  // user is not registered so return success
  $response['status']   = TRUE;
  $response['message']  = 'success;'. t('Start registering process.');
  return $response;
}

/**
* Register the user
*/
function slreguser_full_register(&$sl, $args) {
  $reponse = array();
  $msg = '';

  // check the terminal password
  if (!module_invoke('sluser', 'terminal_check_password', $args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  // check if the user already have a sluser account
  $values = array(
    'uuid' =>$args['user_key']
  );
  $sluser = sluser_load($values);
  if ($sluser->id) {
    $account = user_load($sluser->uid);
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('You already have an account named "!name" on the site.', array('!name' => $account->name));
    return $response;
  }

  // Verify the syntax of the given name.
  $check_username = user_validate_name($args['website_username']);
  if ($check_username != "") {
    $response['status']   = FALSE;
    $response['message']  = "error;". $check_username;
    return $response;
  }

  // verify the email
  $check_email = user_validate_mail($args['email']);
  if ($check_email != "") {
    $response['status']   = FALSE;
    $response['message']  = "error;". $check_email;
    return $response;
  }

  $name   = $args['website_username'];
  $mail   = $args['email'];
  $pass   = $args['pass'];
  $status = 1;

/*
 * SEP: changed - block user *only* if administrator approval required.
 */
  // define if the user needs to validate email
// TODO : check this
  if (variable_get('slreguser_global_settings_email_verification', 0)) {
    $status = 0;
  }

  // register the user
  $values = array(
    'name'    =>$name,
    'mail'    =>$mail,
    'pass'    =>$pass,
    'status'  =>$status,
  );
  // check for username replacement
  if (variable_get('sluser_global_settings_profile_force_username', 0) && ($args['sl_username'] != $sluser->account->name)) {
    $values['name'] = $args['sl_username'];
    $msg = t("Your username on the web site does not match your avatar name. Your username has been changed and is now the same as your avatar's name. Please use this name to log into the web site.");
  }
  // change the role for the user
  $values['roles'] = $sluser->account->roles + array_filter(variable_get('sluser_global_settings_roles', array()));
  if (variable_get('sluser_global_settings_roles_replace', 0)) {
    $values['roles'] = array_filter(variable_get('sluser_global_settings_roles', array()));
  }
  $account = user_save('', $values);
  if (!$account) {
    $response['status'] = FALSE;
    $response['message'] = "error;". t("Error saving user account.");
    return $response;
  }

  // add or update the sluser
  $args['uid']  = $account->uid;
  $args['name'] = $args['sl_username'];
  $args['uuid'] = $args['user_key'];
  unset($args['sl_username']);
  $saved = sluser_save($args);
  $response['status']   = $saved['status'];
  $response['message']  = $saved['message'];
  if ($saved['status'] == FALSE) {
    return $response;
  }

  watchdog('user', 'SlRegUser inworld : New user: %name (%email).', array('%name' => $name, '%email' => $mail), WATCHDOG_NOTICE, l(t('edit'), 'user/'. $account->uid .'/edit'));

  // Add plain text password into user account to generate mail tokens.
    $account->password = $pass;

  // user is registered so check if the user needs a confirmation email
  if (variable_get('slreguser_global_settings_email_verification', 0)) {
    // Create new user account, no administrator approval required but need to confirm email.
    _user_mail_notify('register_no_approval_required', $account);
    $response['status']   = TRUE;
    $response['message']  = "success need activate;". t('Your password and further instructions have been sent to your e-mail address.'). ' '. $msg;
    return $response;
  }
  else if (variable_get('slreguser_global_settings_admin_approval_required', 0)) {
    // Create new user account, administrator approval required.
    _user_mail_notify('register_pending_approval', $account);
    $response['status']   = TRUE;
    $response['message']  = "success need activate;". t('Thank you for applying for an account. Your account is currently pending approval by the site administrator.<br />In the meantime, a welcome message with further instructions has been sent to your e-mail address.'). ' '. $msg;
    return $response;
  }
  else if ($status == 1) {
    // Create new user account, no administrator approval required.
    _user_mail_notify('register_no_approval_required', $account);
    $response['status']   = TRUE;
    $response['message']  = "success reg complete;". t('Your password and further instructions have been sent to your e-mail address.'). ' '. $msg;
    return $response;
  }
}


/**
* Register the user
*/
function slreguser_quick_register(&$sl, $args) {
  global $base_url;
  $reponse = array();

  // check if terminal is disabled
  $terminal_enabled = slterminals_check_disabled($sl->objectkey);
  if (!$terminal_enabled['success']) {
    $response['status']  = FALSE;
    $response['message'] = 'disable;'. $terminal_enabled['message'];
    return $response;
  }

  $terminal = $terminal_enabled['data']['terminal'];
  $grid     = $terminal_enabled['data']['grid'];

  // check the terminal password
  $params = array(
    'pass'            => $args['password'],
    'key'             => $args['keypass'],
    'use_token'       => TRUE,
    'token_sent'      => $args['token'],
    'terminal_token'  => $terminal->token
  );
  $pass_check = slterminals_check_password($params);
  if (!$pass_check['success']) {
    $response['status']   = FALSE;
    $response['message']  = 'disable;'. $pass_check['message'];
    return $response;
  }

  // check if quick registration is allowed
  if (isset($args['quick_register']) && $args['quick_register'] == 1) {
    if (variable_get('slreguser_global_settings_quick_registration_enable', 1) == 0) {
      $response['status']   = FALSE;
      $response['message']  = 'registration closed;'. t('Registration is closed.');
      return $response;
    }
  }

  // get vars
  $msg = '';
  $user_key = $args['user_key'];
  $user_name = $args['user_name'];

  // Verify the syntax of the given name.
  $check_username = user_validate_name($user_name);
  if ($check_username != "") {
    $response['status']   = FALSE;
    $response['message']  = "error;". $check_username;
    return $response;
  }

  // check if this username is already registered
  $account = user_load(array('name' => $user_name));

  if ($account->uid) {
    $msg .= t("The user !username is already registered on the website", array('!username' => $account->name));

    // check if this user is already linked to this avatar
    $avatar = sluser_check_avatar_linked($user_key, $grid->nid, $account->uid);

    if ($avatar) {
      $msg .= "\n". t("and linked to this avatar on the same grid.");
      $pass = user_password(6);

      $values = array(
        'pass' => $pass,
      );

      $updated = user_save($account, $values);
      if (!$updated) {
        $msg .= "\n". t("Error saving user account.");
      }
      else {
        $msg .= "\n". t('Your password is : "!pass". (without quotes and case sensitive)', array('!pass'=>$pass));
      }
    }
    else {
      $msg .= " ". t('but not linked to this avatar on the same grid.'). "\n". t('You need to authenticate your avatar using the regkey available on the website.');
      module_load_include("inc", "sluser", "sluser.inworld");
      return sluser_inworld_get_reg_key($sl, $args);
    }

    $response['status']   = FALSE;
    $response['message']  = 'error;'. $msg;
    return $response;
  }

  $msg .= "\n". t("The user !username is not yet registered on the website", array('!username' => $user_name));
  $msg .= "\n". t('The new account creation process has started.');

  // create the avatar object
  $avatar = new stdclass;
  $avatar->user_uuid = $user_key;
  $avatar->user_name = $user_name;
  $avatar->grid_nid = $grid->nid;
  $avatar->title = $user_name;
  $avatar->type = 'avatar';
  $avatar->link_status = 1;

  // create the user
  $values = array(
    'name'    => $user_name,
    'mail'    => slreguser_build_email_address($avatar),
    'pass'    => user_password(6),
    'status'  => 1,
  );
/*
  // change the role for the user
  $values->roles = $sluser->account->roles + array_filter(variable_get('sluser_global_settings_roles', array()));
  if (variable_get('sluser_global_settings_roles_replace', 0)) {
    $values->roles = array_filter(variable_get('sluser_global_settings_roles', array()));
  }
*/
  $account = user_save('', $values);

  if (!$account) {
    $msg .= "\n". t("Error saving user account.");
    $response['status'] = FALSE;
    $response['message'] = "error;". $msg;
    return $response;
  }

  // save the avatar
  $avatar->uid = $account->uid;
  node_save($avatar);

  watchdog('user', 'SlRegUser inworld quick register : New user: %name (%email).', array('%name' => $account->name, '%email' => $account->mail), WATCHDOG_NOTICE, l(t('edit'), 'user/'. $account->uid .'/edit'));
  $msg .= "\n". t('Your account is now enabled.');
  $msg .= "\n". t('You can log in the website : !link', array('!link'=>$base_url. '/user'));
  $msg .= "\n". t('using your inworld username : "!username"', array('!username'=>$account->name));
  $msg .= "\n". t('Your password is : "!pass". (without quotes and case sensitive)', array('!pass'=>$values['pass']));
  $response['status']   = FALSE;
  $response['message']  = "success reg complete;". $msg;
  return $response;
}
