<?php
// $Id:

function slterminals_views_data()  {

  $data = array();
  $data['sluser_terminals']['table']['group']  = t('SlTerminals');

  // tables + fields that can be used for SQL Joins
  $data['sluser_terminals']['table']['join'] = array(
    'node_revisions' => array(
      'left_field' => 'vid',
      'field' => 'vid',
    ),
    'node' => array(
      'left_field' => 'vid',
      'field' => 'vid',
    ),
    'sluser_grids' => array(
      'left_field' => 'nid',
      'field' => 'grid_nid',
    ),
    'sluser_user' => array(
      'left_field' => 'nid',
      'field' => 'grid_nid',
    ),
  );
// grid_nid
  $data['sluser_terminals']['grid_nid'] = array(
    'title' => t('grid_nid'),
    'help' => t('grid_nid.'),

    'field' => array(
      'handler' => 'views_handler_field_numeric',
      'click sortable' => TRUE,
     ),
    'filter' => array(
      'handler' => 'views_handler_filter_numeric',
    ),
    'sort' => array(
      'handler' => 'views_handler_sort',
    ),
  );
// sim_hostname
  $data['sluser_terminals']['sim_hostname'] = array(
    'title' => t('sim_hostname'),
    'help' => t('sim_hostname.'),

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
// object_name
  $data['sluser_terminals']['object_name'] = array(
    'title' => t('object_name'),
    'help' => t('object_name.'),

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
// object_uuid
  $data['sluser_terminals']['object_uuid'] = array(
    'title' => t('object_uuid'),
    'help' => t('object_uuid.'),

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
// region
  $data['sluser_terminals']['region'] = array(
    'title' => t('region'),
    'help' => t('region.'),

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
// position
  $data['sluser_terminals']['position'] = array(
    'title' => t('position'),
    'help' => t('position.'),

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
// rpc_channel
  $data['sluser_terminals']['rpc_channel'] = array(
    'title' => t('rpc_channel'),
    'help' => t('rpc_channel.'),

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
// http_url
  $data['sluser_terminals']['http_url'] = array(
    'title' => t('http_url'),
    'help' => t('http_url.'),

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
// owner_uuid
  $data['sluser_terminals']['owner_uuid'] = array(
    'title' => t('owner_uuid'),
    'help' => t('owner_uuid.'),

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
// owner_name
  $data['sluser_terminals']['owner_name'] = array(
    'title' => t('owner_name'),
    'help' => t('owner_name.'),

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

  //  Use slterminals as a new base table
  //     by creating a new views type called 'Node example'
  //  This allows it to be selected as the 'view type'
  //          when you initially add a new view.
  $data['sluser_terminals']['table']['base'] = array(
    'field' => 'vid',
    'title' => t('SlTerminals'),
    'help' => t("slterminals informations."),
    'weight' => -9,
  );

  // When using the new 'Node example' type you need to use relationships
  //   to access fields in other tables.

  // Relationship to the 'Node revision' table
  $data['sluser_terminals']['vid'] = array(
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
  $data['sluser_terminals']['nid'] = array(
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

  // Relationship to the 'Grid' table
  $data['sluser_terminals']['grid_nid'] = array(
    'title' => t('Grid'),
    'help' => t('The particular node the grid is attached to'),
    'relationship' => array(
      'label' => t('Grid'),
      'base' => 'node',
      'base field' => 'nid',
    ),
  );
//  **** End optional extra for type and relationships

  return $data;
}

