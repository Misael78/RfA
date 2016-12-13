<?php

/**
 * @file
 */

$plugin = array(
  'category' => t('Roomify Dashboard'),
  'title' => t('Manage featured areas'),
  'render callback' => 'roomify_dashboard_featured_areas_render',
);

/**
 *
 */
function roomify_dashboard_featured_areas_render($subtype, $conf, $args, $pane_context, $incoming_content) {
  $options = array(
    'html' => TRUE,
    'attributes' => array(
      'id' => 'dashboard-manage-featured-properties',
    ),
    'query' => array(
      'destination' => 'user',
    ),
  );

  $block = new stdClass();
  $block->content = '<p>' . l('<strong>' . t('Manage Featured Areas') . '</strong><br />' . t('Define a list of featured Areas that will be shown in some places such as the Homepage'), 'admin/structure/entityqueue/list/featured_areas/subqueues/2/edit', $options) . '</p>';

  return $block;
}