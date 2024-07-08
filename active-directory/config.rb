CONFIG = {
  :domain_name      => "contoso.com",
  :dc01_ip          => "192.168.56.50",
  :mssql01_ip       => "192.168.56.51",
  :mssql02_ip       => "192.168.56.52",
  :web01_ip         => "192.168.56.53",
  :adcs01_ip        => "192.168.56.54",
  :srv01_ip         => "192.168.56.55",
  :srv02_ip         => "192.168.56.56",
  :workstation01_ip => "192.168.56.57",
  :attackbox_ip     => "192.168.56.60",

  :windows_username => "vagrant",
  :windows_password => "vagrant",
  :linux_username   => "root",
  :linux_password   => "root",

  :install_guest_additions => true
}
