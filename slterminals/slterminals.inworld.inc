<?php
// $Id: sluser.inworld.inc,v 1.16 2010/06/18 21:00:07 ssm2017binder Exp $
/**
 * @package	SlUser
 * @copyright	Copyright (C) 2009 Wene / ssm2017 Binder (S.Massiaux). All rights reserved.
 * @license		GNU/GPL, http://www.gnu.org/licenses/gpl-2.0.html
 * SlUser is free software. This version may have been modified pursuant to the GNU General Public License,
 * and as distributed it includes or is derivative of works licensed under the GNU General Public License
 * or other free or open source software licenses.
 */

/**
 * Route commands
 */
function slterminals_inworld_controller($cmd, &$sl, $args) {
  $response = array();
  switch ($cmd) {
    case 'registerTerminal':
    case 'updateTerminal':
      $response = slterminals_register_terminal($sl, $args);
      break;

    case 'log':
      $response = slterminals_log($sl, $args);
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
 * Register the terminal
 */
function slterminals_register_terminal(&$sl, $args) {
  $response = array();

  // check the terminal password
  if (!slterminals_check_password($args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  $args_separator = $sl->args_separator;

  // check if this grid exists
  //$grid_login_uri = urldecode($args['grid_login_uri']);
  $grid_login_uri = $args['grid_login_uri'];
  $grid = db_fetch_object(db_query("SELECT nid FROM {sluser_grids} WHERE login_uri = '%s'", $grid_login_uri));
  if (!$grid->nid) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('The login uri : @login_uri is not registered on the website.', array('@login_uri'=>$grid_login_uri));
    return $response;
  }

  // check if the terminal exists
  $node = new stdclass;
  $node->type = 'terminal';
  $node->title = $sl->objectname;
  $node->uid = variable_get('slterminals_global_settings_defaut_terminal_uid', "0");
  $exists = FALSE;
  $terminal = db_fetch_object(db_query("SELECT nid FROM {sluser_terminals} WHERE object_uuid = '%s'", $sl->objectkey));
  if ($terminal->nid) {
    $node = node_load($terminal->nid);
    $exists = TRUE;
  }

  $node->grid_nid     = $grid->nid;
  $node->sim_hostname = $args['sim_hostname'];
  $node->object_name  = $sl->objectname;
  $node->object_uuid  = $sl->objectkey;
  $node->region       = $sl->region_name;
  $node->position     = strtr($sl->position, array('(' =>'', ')' =>'', ',' =>'/', ' '=>''));
  $node->owner_uuid   = $sl->ownerkey;
  $node->owner_name   = $sl->ownername;

  if ($args['rpc_channel'] != '') {
    $node->rpc_channel = $args['rpc_channel'];
  }
  if ($args['http_url'] != '') {
    $node->http_url = $args['http_url'];
  }
  node_save($node);
  $response['status']   = TRUE;
  $response['message']  = $exists ? 'success;'. t('Terminal updated.') : 'success;'. t('New terminal added.');
  return $response;
}

function slterminals_log($sl, $args) {
  $response = array();
  $msg = '';

  // check the terminal password
  if (!sluser_check_password($args['password'], $args['keypass'])) {
    $response['status']   = FALSE;
    $response['message']  = 'error;'. t('Wrong terminal password.');
    return $response;
  }

  watchdog('SlUser', '!message', array('!message' => $args['message']), (int)$args['severity']);
}
