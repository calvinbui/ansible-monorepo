#!/usr/bin/perl

# author: Sebastian P.
# version: 1.0
#
# usage:
# perl piwigo_import_tree.pl
#    --base_url=http://address/of/your/piwigo
#    --user=your_username
#    --password=your_password
#    --directory=absolute path to your photos
#    [--caddie=0 or 1]
#    [--privacy_level=4 or 8]
#    [--cat=categorie_id]
#    [--subcat=0 or 1]

use strict;
use warnings;

# make it compatible with Windows, but breaks Linux
#use utf8;

use File::Find;
use Data::Dumper;
use File::Basename;
use LWP::UserAgent;
use JSON;
use Getopt::Long;
use Encode qw/is_utf8 decode/;
use Time::HiRes qw/gettimeofday tv_interval/;
use Digest::MD5 qw/md5 md5_hex/;

my %opt = ();
GetOptions(
  \%opt,
  qw/
  base_url=s
  username=s
  password=s
  directory=s
  caddie=s
  privacy_level=s
  /
);

my $album_dir = $opt{directory};
$album_dir =~ s{^\./*}{};

our $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/piwigo_refresh.pl 1.00');
$ua->cookie_jar({});

my %conf;
my %conf_default = (
  base_url => 'http://localhost:81/piwigogit',
  username => 'plg',
  password => 'plg',
  caddie => 0,
  privacy_level => 4,
);

foreach my $conf_key (keys %conf_default) {
  $conf{$conf_key} = defined $opt{$conf_key} ? $opt{$conf_key} : $conf_default{$conf_key}
}

$ua->default_headers->authorization_basic(
  $conf{username},
  $conf{password}
);

my $result = undef;
my $query = undef;

binmode STDOUT, ":encoding(utf-8)";

# Login to Piwigo
piwigo_login();

piwigo_refresh();

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------

sub piwigo_login {
  $ua->post(
    $conf{base_url}.'/ws.php?format=json',
    {
      method => 'pwg.session.login',
      username => $conf{username},
      password => $conf{password},
    }
  );
}

sub piwigo_refresh {
  $ua->post(
    $conf{base_url}.'/admin.php?page=site_update&site=2',
    {
      sync => 'files',
      display_info => 0,
      add_to_caddie => $conf{caddie},
      privacy_level => $conf{privacy_level},
      sync_meta  => 1,
      simulate => 0,
      'subcats-included' => 1,
      submit => 1,
    }
  );
}
