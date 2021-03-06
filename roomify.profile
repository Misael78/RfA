<?php


/**
 * Implements hook_form_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function roomify_form_install_configure_form_alter(&$form, $form_state) {
  // When using Drush, let it set the default password.
  if (drupal_is_cli()) {
    return;
  }
  // Set a default name for the dev site and change title's label.
  $form['site_information']['site_name']['#title'] = 'Roomify Site Name';
  $form['site_information']['site_mail']['#title'] = 'Roomify Site Email';
  $form['site_information']['site_name']['#default_value'] = st('Roomify');

  // Set a default country so we can benefit from it on Address Fields.
  $form['server_settings']['site_default_country']['#default_value'] = 'US';

  // Use "admin" as the default username.
  $form['admin_account']['account']['name']['#default_value'] = 'admin';

  // Set the default admin password.
  $form['admin_account']['account']['pass']['#value'] = 'admin';

  // Hide Update Notifications.
  $form['update_notifications']['#access'] = FALSE;

  // Add informations about the default username and password.
  $form['admin_account']['account']['roomify_name'] = array(
    '#type' => 'item',
    '#title' => st('Username'),
    '#markup' => 'admin'
  );
  $form['admin_account']['account']['roomify_password'] = array(
    '#type' => 'item',
    '#title' => st('Password'),
    '#markup' => 'admin'
  );
  $form['admin_account']['account']['roomify_informations'] = array(
    '#markup' => '<p>' . t('This information will be emailed to the store email address.') . '</p>'
  );
  $form['admin_account']['override_account_informations'] = array(
    '#type' => 'checkbox',
    '#title' => t('Change my username and password.'),
  );
  $form['admin_account']['setup_account'] = array(
    '#type' => 'container',
    '#parents' => array('admin_account'),
    '#states' => array(
      'invisible' => array(
        'input[name="override_account_informations"]' => array('checked' => FALSE),
      ),
    ),
  );

  // Make a "copy" of the original name and pass form fields.
  $form['admin_account']['setup_account']['account']['name'] = $form['admin_account']['account']['name'];
  $form['admin_account']['setup_account']['account']['pass'] = $form['admin_account']['account']['pass'];
  $form['admin_account']['setup_account']['account']['pass']['#value'] = array('pass1' => 'admin', 'pass2' => 'admin');

  // Use "admin" as the default username.
  $form['admin_account']['account']['name']['#access'] = FALSE;

  // Make the password "hidden".
  $form['admin_account']['account']['pass']['#type'] = 'hidden';
  $form['admin_account']['account']['mail']['#access'] = FALSE;

  // Add a custom validation that needs to be trigger before the original one,
  // where we can copy the site's mail as the admin account's mail.
  array_unshift($form['#validate'], 'roomify_custom_setting');
}

/**
 * Validate callback; Populate the admin account mail, user and password with
 * custom values.
 */
function roomify_custom_setting(&$form, &$form_state) {
  $form_state['values']['account']['mail'] = $form_state['values']['site_mail'];
  // Use our custom values only the corresponding checkbox is checked.
  if ($form_state['values']['override_account_informations'] == TRUE) {
    if ($form_state['input']['pass']['pass1'] == $form_state['input']['pass']['pass2']) {
      $form_state['values']['account']['name'] = $form_state['values']['name'];
      $form_state['values']['account']['pass'] = $form_state['input']['pass']['pass1'];
    }
    else {
      form_set_error('pass', st('The specified passwords do not match.'));
    }
  }
}

/**
 * Implements hook_mail().
 */
function roomify_mail($key, &$message, $params) {
  switch($key) {
    case 'roomify_new_account_email':
      $message['subject'] = 'Your new Roomify site!';
      $message['body'][] = <<<EOF
Hello!

Thank you for signing up for your own Roomify Accommodations site. The gears have turned and your site is ready to make you money!

Please use the following link to choose a new password. Be sure to use a secure password, or your competition might try to raise your prices!

{$params['one_time_link']}

This link can only be used once, and it is only valid for 24 hours. If you were unexpectedly detained for longer than this, and were unable to use the link within that period, please use the following link to request a new one. (Be sure to enter the email address you used when signing up)

{$params['reset_link']}

After setting your password, you will be logged into your site. For future logins, go to:

{$params['login_link']}

and use the following credentials:

username: {$params['customer_email']}
password: The password you chose.

regards,
the Roomify team
EOF;
      break;
  }
}
