<?php
// $Id:

/*
*  This file is used to tell the views module about the new sluser table.
*
* Database definition:
* @code
*   CREATE TABLE sluser (
*     vid int(10) unsigned NOT NULL default '0',
*     nid int(10) unsigned NOT NULL default '0',
*     color varchar(255) NOT NULL default '',
*     quantity int(10) unsigned NOT NULL default '0',
*     PRIMARY KEY (vid, nid),
*     KEY <code>sluser_nid</code> (nid)
*   )
* @endcode
*/

function sluser_views_data()  {
  // Basic table information.

  // ----------------------------------------------------------------
  // sluser table
  //  New group within Views called 'Example'

  $data = array();
  $data['sluser']['table']['group']  = t('SlUser');

  // tables + fields that can be used for SQL Joins
  $data['sluser']['table']['join'] = array(
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
    'sluser_terminals' => array(
      'left_field' => 'nid',
      'field' => 'grid_nid',
    ),
  );

//grid_nid

  // Color     
  $data['sluser']['user_name'] = array(
    'title' => t('user_name'),
    'help' => t('user_name.'),

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

  $data['sluser']['user_uuid'] = array(
    'title' => t('user_uuid'),
    'help' => t('user_uuid.'),

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

  $data['sluser']['grid_nid'] = array(
    'title' => t('grid_nid'),
    'help' => t('grid_nid.'),

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

  //  Use sluser as a new base table
  //     by creating a new views type called 'Node example'
  //  This allows it to be selected as the 'view type'
  //          when you initially add a new view.
  $data['sluser']['table']['base'] = array(
    'field' => 'vid',
    'title' => t('SlUser'),
    'help' => t("SlUser informations."),
    'weight' => -9,
  );

  // When using the new 'Node example' type you need to use relationships
  //   to access fields in other tables.

  // Relationship to the 'Node revision' table
  $data['sluser']['vid'] = array(
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
  $data['sluser']['nid'] = array(
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
  $data['sluser']['grid_nid'] = array(
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

