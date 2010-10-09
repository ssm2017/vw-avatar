<div class="slterminals_info">
  <ul>
    <li><?php print t('object_name'); ?> : <?php print $node->object_name; ?></li>
    <li><?php print t('region'); ?> : <?php print $node->region; ?></li>
    <li><?php print t('position'); ?> : <?php print $node->position; ?></li>
    <li><?php print t('owner_name'); ?> : <?php print $node->owner_name; ?></li>
    <li><?php print t('Status'); ?> : <span id="terminal-<?php print $node->nid; ?>-status"><span><?php print t('Checking....'); ?></span></span></li>
  </ul>
</div>
