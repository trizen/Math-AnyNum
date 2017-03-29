
use utf8;
use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
     module_name        => 'Math::AnyNum',
     license            => 'artistic_2',
     dist_author        => q{Daniel Șuteu <trizenx@gmail.com>},
     dist_version_from  => 'lib/Math/AnyNum.pm',
     release_status     => 'stable',
     configure_requires => {
                            'Module::Build' => 0,
                           },
     build_requires => {
                        'Test::More' => 0,
                       },
     requires => {
                  'POSIX'               => 0,
                  'Math::GMPq'          => 0.41,
                  'Math::GMPz'          => 0.39,
                  'Math::MPC'           => 1.07,
                  'Math::MPFR'          => 3.29,
                  'Class::Multimethods' => 1.70,
                 },
     add_to_cleanup     => ['Math-AnyNum-*'],
     create_makefile_pl => 'traditional',
);

$builder->create_build_script();
