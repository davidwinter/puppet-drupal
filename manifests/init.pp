class drupal (
	$version = '7.16',
	$root    = '/var/www',
) {

	package { 'wget':
		ensure => present,
	}
	
	exec { 'download':
		command => "wget -O /tmp/drupal-$version.tar.gz http://ftp.drupal.org/files/projects/drupal-$version.tar.gz",
		unless  => "test -f /tmp/drupal-$version.tar.gz",
	}

	exec { 'extract':
		command => "sudo tar xvfz /tmp/drupal-$version.tar.gz -C $root",
		creates => "$root/drupal-$version",
		require => Exec['download'],
		returns => 2, # due to permissions issue with puppet
	}

	exec { 'move files into correct location':
		command => "mv $root/drupal-$version/* $root/",
		creates => "$root/index.php",
		require => Exec['extract'],
	}

	file { 'remove old extract directory':
		path    => "$root/drupal-$version",
		require => Exec['move files into correct location'],
		ensure  => absent,
		force   => true,
	}

	file { 'settings':
		ensure  => file,
		path    => "$root/sites/default/settings.php",
		source  => "$root/sites/default/default.settings.php",
		mode    => 'a+w',
		require => Exec['extract'],
	}

	file { 'default directory':
		ensure  => directory,
		path    => "$root/sites/default",
		mode    => 'a+w',
		require => File['settings'],
	}

}