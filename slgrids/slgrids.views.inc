<?php
// $Id:

function slgrids_views_data()  {

  $data = array();
  $data['slgrids']['table']['group']  = t('slgrids');

  // tables + fields that can be used for SQL Joins
  $data['slgrids']['table']['join'] = array(
    'node_revisions' => array(
      'left_field' => 'vid',
      'field' => 'vid',
    ),
    'node' => array(
      'left_field' => 'vid',
      'field' => 'vid',
    ),
    'sluser' => array(
      'left_field' => 'grid_nid',
      'field' => 'nid',
    ),
    'sluser_terminals' => array(
      'left_field' => 'grid_nid',
      'field' => 'nid',
    ),
  );

// login_uri
  $data['slgrids']['login_uri'] = array(
    'title' => t('login_uri'),
    'help' => t('login_uri.'),

    'field' => array(
      'handler' => 'views_handler_field',
      'click sortable' => TRUE,
     ),
     'filter' => array(
      'handler' => 'views_handler_filter_string',
     ),
     'argument' => array(
       'handler' => 'views_handler_argument_string',
     ),
     'sort' => array(
      'handler' => 'views_handler_sort',
     ),
  );
// xmlrpc_url
  $data['slgrids']['xmlrpc_url'] = array(
    'title' => t('xmlrpc_url'),
    'help' => t('xmlrpc_url.'),

    'field' => array(
      'handler' => 'views_handler_field',
      'click sortable' => TRUE,
     ),
     'filter' => array(
      'handler' => 'views_handler_filter_string',
     ),
     'argument' => array(
       'handler' => 'views_handler_argument_string',
     ),
     'sort' => array(
      'handler' => 'views_handler_sort',
     ),
  );
// httpIn_url
  $data['slgrids']['httpIn_url'] = array(
    'title' => t('httpIn_url'),
    'help' => t('httpIn_url.'),

    'field' => array(
      'handler' => 'views_handler_field',
      'click sortable' => TRUE,
     ),
     'filter' => array(
      'handler' => 'views_handler_filter_string',
     ),
     'argument' => array(
       'handler' => 'views_handler_argument_string',
     ),
     'sort' => array(
      'handler' => 'views_handler_sort',
     ),
  );

//  **** Begin optional extra for type and relationships

  //  Use slgrids as a new base table
  //     by creating a new views type called 'Node example'
  //  This allows it to be selected as the 'view type'
  //          when you initially add a new view.
  $data['slgrids']['table']['base'] = array(
    'field' => 'vid',
    'title' => t('SlGrids'),
    'help' => t("slgrids informations."),
    'weight' => -9,
  );

  // When using the new 'Node example' type you need to use relationships
  //   to access fields in other tables.

  // Relationship to the 'Node revision' table
  $data['slgrids']['vid'] = array(
    'title' => t('Node revision'),
    'help' => t('The particular node revision the color and quantity is attached to'),
    'relationship' => array(
      'label' => t('Node revision'),
      'base' => 'node_revisions',
      'base field' => 'vid',
      // This allows us to not show this relationship if the base is already
      // node_revisions so users won't create circular relationships.
      'skip base' => array('node', 'node_revisions'),
    ),
  );

  // Relationship to the 'Node' table
  $data['slgrids']['nid'] = array(
    'title' => t('Node'),
    'help' => t('The particular node the color and quantity is attached to'),
    'relationship' => array(
      'label' => t('Node'),
      'base' => 'node',
      'base field' => 'nid',
      // This allows us to not show this relationship if the base is already
      // node so users won't create circular relationships.
      'skip base' => array('node', 'node_revisions'),
    ),
  );

  // Relationship to the 'SlUser' table
  $data['slgrids']['nid'] = array(
    'title' => t('SlUser'),
    'help' => t('The particular sluser the grid is attached to'),
    'relationship' => array(
      'label' => t('SlUser'),
      'base' => 'sluser',
      'base field' => 'grid_nid',
      // This allows us to not show this relationship if the base is already
      // node so users won't create circular relationships.
      'skip base' => array('node', 'sluser'),
    ),
  );

  // Relationship to the 'SlTerminals' table
  $data['slgrids']['nid'] = array(
    'title' => t('SlTerminals'),
    'help' => t('The particular terminal the grid is attached to'),
    'relationship' => array(
      'label' => t('SlTerminals'),
      'base' => 'sluser_terminals',
      'base field' => 'grid_nid',
      // This allows us to not show this relationship if the base is already
      // node so users won't create circular relationships.
      'skip base' => array('node', 'sluser_terminals'),
    ),
  );
//  **** End optional extra for type and relationships

  return $data;
}

