<div class="slterminals_info">
  <ul>
    <li><?php print t('grid_nid'); ?> : <?php print $node->grid_nid; ?></li>
    <li><?php print t('sim_hostname'); ?> : <?php print $node->sim_hostname; ?></li>
    <li><?php print t('object_name'); ?> : <?php print $node->object_name; ?></li>
    <li><?php print t('object_uuid'); ?> : <?php print $node->object_uuid; ?></li>
    <li><?php print t('region'); ?> : <?php print $node->region; ?></li>
    <li><?php print t('position'); ?> : <?php print $node->position; ?></li>
    <li><?php print t('rpc_channel'); ?> : <?php print $node->rpc_channel; ?></li>
    <li><?php print t('http_url'); ?> : <?php print $node->http_url; ?></li>
    <li><?php print t('owner_uuid'); ?> : <?php print $node->owner_uuid; ?></li>
    <li><?php print t('owner_name'); ?> : <?php print $node->owner_name; ?></li>
    <li><?php print t('Status'); ?> : <span id="terminal-<?php print $node->nid; ?>-status"><span><?php print t('Checking....'); ?></span></span></li>
  </ul>
</div>
