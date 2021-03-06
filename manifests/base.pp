# Puppet whines and compains if it doesn't have
# its puppet users  and apt throws a fit if it's out of date,
# so we take care of these things first.

stage { 'first': before => Stage['main'] }

class {
  'vagrantsetup': stage => first;
  'vagrantvm': stage => main;
}

class vagrantvm {
  $user = 'vagrant'
  $group = 'vagrant'

  class { 'webadmin':
    webadminuser => $user,
    webadmingroup => $group,
  }

  # This lovely little hack of instantiating the class
  # we extend before the extending class allows us to get
  # our parameters into it.  Otherwise the parent class does
  # not receive them.
  class { "Php53":
    webadminuser => $user,
    webadmingroup => $group,
    require => Class['webadmin'],
    web_permissions => 'false',
  }

  class { "Php53::Dev":
    webadminuser => $user,
    webadmingroup => $group,
    require => Class['webadmin', 'Php53'],
    web_permissions => 'false',
  }


  # This lovely little hack of instantiating the class
  # we extend before the extending class allows us to get
  # our parameters into it.  Otherwise the parent class does
  # not receive them.
  class { 'Mysql5':
    mysqlpassword => '',
    webadminuser => $user,
    webadmingroup => $group,
  }

  class { 'Mysql5::Dev':
    mysqlpassword => '',
    webadminuser => $user,
    webadmingroup => $group,
    require => Class['webadmin', 'Mysql5'],
  }

  user { "www-data":
    groups => ['dialout']
  }

  class { "solr":
    webadmingroup => $webadmingroup,
  }

  include stylomatic
  include drush
  class { "drushfetcher":
    fetcher_host => 'https://extranet.zivtech.com',
  }
  include drushphpsh
}

include vagrantsetup
include vagrantvm
