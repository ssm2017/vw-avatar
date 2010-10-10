<div class="sluser_info">
  <ul>
    <li><?php print t('uid'); ?> : <?php print $node->uid; ?></li>
    <li><?php print t('grid_nid'); ?> : <?php print $node->grid_nid; ?></li>
    <li><?php print t('grid_name'); ?> : <?php print $node->grid_name; ?></li>
    <li><?php print t('user_name'); ?> : <?php print $node->user_name; ?></li>
    <li><?php print t('user_uuid'); ?> : <?php print $node->user_uuid; ?></li>
    <li><?php print t('reg_key'); ?> : <?php print $node->reg_key; ?></li>
    <li><?php print t('link_status'); ?> : <?php print $node->link_status; ?></li>
    <li><?php print t('link_time'); ?> : <?php print $node->link_time; ?></li>
  </ul>
</div>
<?php print $node->reg_key_form; ?>
