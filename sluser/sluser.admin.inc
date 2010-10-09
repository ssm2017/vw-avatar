<?php
// $Id: sluser.module,v 1.16 2010/04/19 21:57:33 ssm2017binder Exp $
/**
 * @package SlUser
 * @subpackage SlUser
 * @copyright Copyright (C) 2009-2010 Wene / ssm2017 Binder (S.Massiaux). All rights reserved.
 * @license GNU/GPL, http://www.gnu.org/licenses/gpl-2.0.html
 * SlUser is free software. This version may have been modified pursuant to the GNU General Public License,
 * and as distributed it includes or is derivative of works licensed under the GNU General Public License
 * or other free or open source software licenses.
 */

/**
 * Admin settings
 */
function sluser_global_settings_form($form_state) {
  $form = array();
  // load internal forms
  $form['sluser_global_settings'] = array();
  //$form['sluser_global_settings'][] = sluser_global_settings_search_form($form_state, &$edit);
  $form['sluser_global_settings'][] = sluser_global_settings_terminology_form($form_state, &$edit);
  //$form['sluser_global_settings'][] = sluser_global_settings_roles_form($form_state, $edit);
  //$form['sluser_global_settings'][] = sluser_global_settings_terminals_form($form_state, $edit);
  //$form['sluser_global_settings'][] = sluser_global_settings_profile_form($form_state, $edit);
  // get third parties forms
  //$form['sluser_global_settings']['settings'] = module_invoke_all('sluser', 'settings');
  return system_settings_form($form);
}

/**
 * check values before saving
 */
function sluser_global_settings_form_validate($form, &$form_state) {
  // terminology
  $machine_name = $form_state['values']['sluser_global_settings_terminology_sluser_machine_name'];
  $human_name = $form_state['values']['sluser_global_settings_terminology_sluser_human_name'];
  if (!preg_match('!^[a-z0-9_]+$!', $machine_name)) {
    form_set_error('sluser_global_settings_terminology_sluser_machine_name', t('The machine-readable name must contain only lowercase letters, numbers, and underscores.'));
  }
}

/**
 * search settings form
 */
function sluser_global_settings_search_form($form_state, &$edit) {
  $form = array();
  $form['search'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Search'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  $form['search']['sluser_global_settings_search_enable'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Enable search'),
    '#default_value'  => variable_get('sluser_global_settings_search_enable', 1),
    '#description'    => t('If enabled, user will be able to search using avatar names.'),
  );
  return $form;
}

/**
 * terminology settings form
 */
function sluser_global_settings_terminology_form($form_state, &$edit) {
  $form = array();
  $form['terminology'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Terminology'),
    '#collapsible'  => FALSE,
    '#collapsed'    => FALSE,
  );
  // sluser
  $form['terminology']['sluser']['sluser_global_settings_terminology_sluser_machine_name'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Machine name'),
    '#default_value'  => variable_get('sluser_global_settings_terminology_sluser_machine_name',  'sluser'),
    '#description'    => t('Define the machine name to replace "sluser" one. This text will be used for constructing the URL of different pages. This name must contain only lowercase letters, numbers, and underscores.'). t('<strong>You need to clear the cache to see the changes</strong>.'),
  );
  $form['terminology']['sluser']['sluser_global_settings_terminology_sluser_human_name'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Human name'),
    '#default_value'  => variable_get('sluser_global_settings_terminology_sluser_human_name',  'SlUser'),
    '#description'    => t('Define the human name to replace "sluser" one.'). t('<strong>You need to clear the cache to see the changes</strong>.'),
  );
  return $form;
}

/**
 * roles settings form
 */
function sluser_global_settings_roles_form($form_state, &$edit) {
  $form = array();
// roles
  $roles = user_roles(TRUE);
  $checkbox_authenticated = array(
    '#type'           => 'checkbox',
    '#title'          => $roles[DRUPAL_AUTHENTICATED_RID],
    '#default_value'  => TRUE,
    '#disabled'       => TRUE,
  );
  unset($roles[DRUPAL_AUTHENTICATED_RID]);
  if ($roles) {
    $form['roles'] = array(
      '#type'         => 'fieldset',
      '#title'        => t('Roles'),
      '#collapsible'  => TRUE,
      '#collapsed'    => TRUE,
    );
    $form['roles']['sluser_global_settings_roles'] = array(
      '#type'                   => 'checkboxes',
      '#title'                  => t('Default roles for new user'),
      '#default_value'          => variable_get('sluser_global_settings_roles', array()),
      '#options'                => $roles,
      '#description'            => t('Defines the default role when a registered user validates his account from inworld.'),
      DRUPAL_AUTHENTICATED_RID  => $checkbox_authenticated,
    );
    $form['roles']['sluser_global_settings_roles_replace'] = array(
      '#type'                   => 'checkbox',
      '#title'                  => t('Replace roles'),
      '#default_value'          => variable_get('sluser_global_settings_roles_replace', 0),
      '#description'            => t('If checked, the user roles will be replaced by the list above. If not checked, the roles list will be merged.'),
    );
  }
  return $form;
}

/**
 * profile settings form
 */
function sluser_global_settings_profile_form($form_state, &$edit) {
  $form = array();
  // profile view fieldset
  $form['profile'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Profile'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );

  $form['profile']['sluser_global_settings_profile_force_username'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Force username'),
    '#default_value'  => variable_get('sluser_global_settings_profile_force_username', 0),
    '#description'    => t('If checked, the username will be replaced by the inworld username when checking the key.'),
  );

  $form['profile'][] = sluser_global_settings_profile_external_profile_form($form_state, $edit);
  $form['profile'][] = sluser_global_settings_profile_privacy_form($form_state, $edit);
  $form['profile'][] = sluser_global_settings_profile_picture_form($form_state, $edit);

  return $form;
}

/**
 * privacy settings form
 */
function sluser_global_settings_profile_privacy_form($form_state, &$edit) {
  $form = array();
  $form['privacy'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Privacy'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );

  // build the items lists
  $items = sluser_global_settings_profile_build_items_list();

  // tab view
  $form['privacy']['tab_view'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Tab view'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  $form['privacy']['tab_view']['sluser_global_settings_profile_privacy_tab_view_enable'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Enable tab view'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_tab_view_enable', 1),
    '#description'    => t('If enabled, all the users can use the tab view.'),
  );
  $form['privacy']['tab_view']['default'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Defaults'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  $form['privacy']['tab_view']['default']['sluser_global_settings_profile_privacy_tab_view_default_enable'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Display the tab view'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_tab_view_default_enable', 1),
    '#description'    => t('If enabled, all the sluser profiles tab can be viewed by default'),
  );
  $form['privacy']['tab_view']['default']['sluser_global_settings_profile_privacy_tab_view_default_items'] = array(
    '#type'           => 'checkboxes',
    '#title'          => t('Default items to show'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_tab_view_default_items', $items['default']),
    '#options'        => $items['values'],
    '#description'    => t("Define the default items to show on the user's profile tab."),
  );

  // profile view
  $form['privacy']['profile_view'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Profile view'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  $form['privacy']['profile_view']['sluser_global_settings_profile_privacy_profile_view_enable'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Default profile view'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_profile_view_enable', 1),
    '#description'    => t('Define the default profile view for all users (if enabled, all the sluser profiles can be viewed by default)'),
  );
  $form['privacy']['profile_view']['default'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('Defaults'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );
  $form['privacy']['profile_view']['default']['sluser_global_settings_profile_privacy_profile_view_default_enable'] = array(
    '#type'           => 'checkbox',
    '#title'          => t('Default profile view'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_profile_view_default_enable', 1),
    '#description'    => t('Define the default profile view for all users (if enabled, all the sluser profiles can be viewed by default)'),
  );
  $form['privacy']['profile_view']['default']['sluser_global_settings_profile_privacy_profile_view_default_items'] = array(
    '#type'           => 'checkboxes',
    '#title'          => t('Default items to show'),
    '#default_value'  => variable_get('sluser_global_settings_profile_privacy_profile_view_default_items', $items['default']),
    '#options'        => $items['values'],
    '#description'    => t("Define the default items to show on the user's profile tab."),
  );

  return $form;
}


/**
 * external profile settings form
 */
function sluser_global_settings_profile_external_profile_form($form_state, &$edit) {
  $form = array();

  // profile view fieldset
  $form['external_profile'] = array(
    '#type'         => 'fieldset',
    '#title'        => t('External Profile'),
    '#collapsible'  => TRUE,
    '#collapsed'    => TRUE,
  );

  // external profile link model
  $form['external_profile']['sluser_global_settings_profile_external_profile_link'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Profile link model'),
    '#default_value'  => variable_get('sluser_global_settings_profile_external_profile_link', 'http://world.secondlife.com/resident/%uuid'),
    '#description'    => t('Define the profile link model (default is "http://world.secondlife.com/resident/%uuid"). You can add some vars inside :<br/><ul><li>%uuid for user uuid</li><li>%name for user name</li><li>'),
  );
  // inworld profile link model
  $form['external_profile']['sluser_global_settings_profile_inworld_profile_link'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Inworld link model'),
    '#default_value'  => variable_get('sluser_global_settings_profile_inworld_profile_link', 'secondlife:///app/agent/%uuid/about'),
    '#description'    => t('Define the inworld link model (default is "secondlife:///app/agent/%uuid/about"). You can add some vars inside :<br/><ul><li>%uuid for user uuid</li><li>%name for user name</li><li>'),
  );
  return $form;
}
