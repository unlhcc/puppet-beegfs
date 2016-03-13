# puppet-beegfs

## Usage

You need one mgmtd server:

```puppet
class { 'beegfs::mgmtd': }
```

And probably many storage and meta servers:
```puppet
class { 'beegfs::meta':
  mgmtd_host => 192.168.1.1,
}
class { 'beegfs::storage':
  mgmtd_host => 192.168.1.1,
}
```

defining a mount
```puppet
beegfs::mount{ 'mnt-share':
  cfg => '/etc/beegfs/beegfs-client.conf',
  mnt   => '/mnt/share',
  user  => 'beegfs',
  group => 'beegfs',
}
```

### Interfaces

For meta and storage nodes you can specify interfaces for commutication. The passed argument must be an array.

```puppet
class { 'beegfs::meta':
  mgmtd_host => 192.168.1.1,
  interfaces => ['eth0', 'ib0'],
}
class { 'beegfs::storage':
  mgmtd_host => 192.168.1.1,
  interfaces => ['eth0', 'ib0']
}
```

## Hiera support

All configuration could be specified in Hiera config files. Some settings
are shared between all components, like:

```
beegfs::version: '2015.03.r9.debian7'
```

for module specific setting use correct namespace, e.g.:
```
beegfs::meta::interfaces:
  - 'eth0'
```


## License

Apache License, Version 2.0
