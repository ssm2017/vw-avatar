<?php

/**
 * UUID zero
 */
define('UUID_ZERO', '00000000-0000-0000-0000-000000000000');

/**
 *
 */
function sluser_renew_reg_key_form($form_state, $nid) {
  $form = array();

  // fieldset for regkey
  $form['reg_key'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Renew regkey'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  // reg key renew
  $form['reg_key']['renew_regkey_container'] = array(
    '#value'  => '&nbsp;',
    '#prefix' => '<div id="renew-regkey-container">',
    '#suffix' => '</div>',
  );
  $form['reg_key']['item'] = array(
    '#type'   => 'item',
    '#title'  => t('Regkey'),
    '#value'  => t("Push the button if you would like to renew your regkey for this avatar."),
  );
  $form['reg_key']['nid'] = array(
    '#type'   => 'hidden',
    '#value'  => $nid,
  );
  $form['reg_key']['renew_regkey_button'] = array(
    '#type'   => 'submit',
    '#value'  => t('Renew Regkey'),
    '#weight' => 1,
    '#ahah'   => array(
      'path'    => SLUSER_MACHINE_NAME. '/users/renew-regkey/js',
      'wrapper' => 'renew-regkey-container',
      'method'  => 'replace',
      'effect'  => 'fade',
    ),
  );

  return $form;
}

/**
 * Generate a regkey
 */
function sluser_generate_regkey($nid) {
  // generate a reg key
  $node = node_load($nid);
  $node->reg_key = module_invoke('user', 'password');
  node_save($node);
  // TODO : don't show message if user is not enabled
  //if ($account->status) {
    drupal_set_message(t('New reg key is : '). $node->reg_key);
  //}
}

/**
 * AHAH callback to renew the regkey
 */
function sluser_renew_regkey_js() {
  // drupal's alchemy
  $form_state = array('storage' => NULL, 'submitted' => FALSE);
  $form_build_id = $_POST['form_build_id'];
  $form = form_get_cache($form_build_id, $form_state);
  $args = $form['#parameters'];
  $form_id = array_shift($args);
  $form_state['post'] = $form['#post'] = $_POST;
  $form['#programmed'] = $form['#redirect'] = FALSE;
  $renew_regkey_form = $form['sluser']['renew_regkey_container'];
  unset($renew_regkey_form['#prefix'], $renew_regkey_form['#suffix']);
  // generate the regkey
  sluser_generate_regkey($form_state['post']['nid']);
  // return the value
  $output = theme('status_messages') . drupal_render($renew_regkey_form);
  drupal_json(array('status' => TRUE, 'data' => $output));
}

/**
 * Check if the avatar is already linked on the same grid
 */
function sluser_check_avatar_linked($user_uuid, $grid_nid, $uid) {
  $query = "SELECT n.*, su.* FROM {node} AS n"
          . " LEFT JOIN {sluser} AS su ON su.user_uuid='%s' AND su.grid_nid='%s'"
          . " WHERE n.uid=%d AND n.nid=su.nid";
  return db_fetch_object(db_query($query, $user_uuid, $grid_nid, $uid));
}

/**
 * Build a link request
 */
function sluser_build_link_request($params) {
  $avatar               = new stdclass;
  $avatar->title        = $params['user_name'];
  $avatar->user_name    = $params['user_name'];
  $avatar->user_uuid    = $params['user_uuid'];
  $avatar->grid_nid     = $params['grid_nid'];
  $avatar->type         = 'avatar';
  $avatar->link_status  = 0;
  $avatar->link_time    = time();
  $avatar->reg_key      = $params['reg_key'];
  node_save($avatar);
  if ($avatar->nid) {
    return $avatar;
  }
  return FALSE;
}

/**
 * Generates a uuid
 * @return String The uuid
 */
function sluser_uuid_create() {
  return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
  mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),
  mt_rand( 0, 0x0fff ) | 0x4000,
  mt_rand( 0, 0x3fff ) | 0x8000,
  mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ) );
}
