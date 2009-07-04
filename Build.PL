use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'FTN::Addr',
    license             => 'perl',
    dist_author         => 'Valery Kalesnik <valkoles@gmail.com>',
    dist_version_from   => 'lib/FTN/Addr.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'FTN-Addr-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
