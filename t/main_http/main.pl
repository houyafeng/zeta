#!/usr/bin/perl

use Zeta::Run;
use Zeta::Run::Main::HTTP;
sub {
    Zeta::Run::Main::HTTP->run( port => 8888, module => 'MyAdmin');
};

