<?php

/**
 * Create some blocks
 */
function sluser_block($op = 'list', $delta = '', $edit = array()) {
  global $user;
  switch ($op) {

    case 'list':
      $blocks['validate-form'] = array(
        'title' => t('Key validator'),
        'info'  => t('Inworld validation key form.'),
      );
      return $blocks;

    case 'view':
      switch ($delta) {

        case 'validate-form':
          if ($user->uid != 0) {
            $block['title'] = t('Key validator');
            $block['subject'] = t('Title of configurable-text block');
            $block['content'] = drupal_get_form('sluser_validation_form');
          }
          break;
      }
      return $block;
  }
}

/**
 * Form in the block
 */
function sluser_validation_form($form_state) {
  $form = array();
  if (!isset($form_state['storage']['confirm'])) {
    $form['validation_key'] = array(
      '#type' => 'textfield',
      '#title' => t('Validation key'),
      '#size' => 10,
      '#description' => t('Please enter the validation key you get inworld.'),
    );
    $form['submit'] = array('#type' => 'submit', '#value' => t('Save'));
  }
  else {
    $form['nid'] = array(
      '#type' => 'hidden',
      '#value' => $form_state['values']['avatar']->nid,
    );
    return confirm_form($form, t('Are you Sure?'),$_GET['q'],t('Do you really want to link your account to the avatar named @avatar ?', array('@avatar' => $form_state['values']['avatar']->user_name)), t('Yes'), t('Cancel'));
  }
  return $form;
}

/**
 * Block form validation
 */
function sluser_validation_form_validate($form, &$form_state) {
  global $user;
  if (!isset($form_state['storage']['confirm'])) {
    $validation_key = $form_state['values']['validation_key'];

    if ($validation_key == '') {
      form_set_error('validation_key', t('You must enter a value.'));
    }

    // check if the key exists
    $query = "SELECT * FROM {sluser} WHERE reg_key='%s' AND link_status = 0";
    $avatar = db_fetch_object(db_query($query, $validation_key));
    $form_state['values']['avatar'] = $avatar;

    if (!$avatar) {
      form_set_error('validation_key', t('You must enter a valid key.'));
    }

    // check if there is already a user link with this avatar
    $query = "SELECT a.*, n.* FROM {sluser} AS a"
          . " LEFT JOIN {node} AS n ON n.nid=a.nid"
          . " WHERE a.user_uuid='%s' AND a.link_status = 1 AND n.uid=%d";
    $result = db_fetch_object(db_query($query, $avatar->user_uuid, $user->uid));
    if ($result) {
      form_set_error('validation_key', t('This avatar is already registered with your account.'));
    }
  }
}

/**
 * Block form submission
 */
function sluser_validation_form_submit($form, &$form_state) {
  global $user;
  if (!$form_state['storage']['confirm']) {
    $form_state['storage']['confirm'] = TRUE;
    $form_state['rebuild'] = TRUE;
  }
  else {
    // get the avatar
    $avatar = node_load($form_state['values']['nid']);
    $avatar->uid = $user->uid;
    $avatar->link_status = 1;
    node_save($avatar);
    drupal_set_message(t('Key recognized. You can see the profile here : !profile', array('!profile' => l($avatar->title, 'node/'. $avatar->nid))));

    cache_clear_all();
    drupal_goto('node/'. $avatar->nid);
  }
}
