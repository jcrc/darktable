#!/usr/bin/perl
#  This file is part of darktable,
#  copyright (c) 2013-2014 tobias ellinghaus.
#
#  darktable is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  darktable is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with darktable.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use File::Copy qw(copy); # as a fallback

use scanner;
use parser;
use ast;
use code_gen;

my $input_file = $ARGV[0];
my $output_file = $ARGV[1];

if(!defined($input_file) or !defined($output_file))
{
  print "usage: parse.pl <input file> <output_file>\n";
  exit(1);
}

read_file($input_file);

my %types;
my $version = -1;
my $params_type = "";

while()
{
  @token = get_token();
  last if($token[$P_TYPE] == $T_NONE);
  if(istypedef(\@token))
  {
    my $ast = parse();
    if(defined($ast))
    {
      $ast->fix_types(\%types);
  #     $ast->print_tree(0);
  #     print "===========\n";
      $types{$ast->{name}} = \$ast;
    }
  }
  elsif(isdtmoduleintrospection(\@token))
  {
    ($version, $params_type) = parse_dt_module_introspection();
  }
}

if($params_type ne "")
{
  # needed for variable metadata like min, max, default and description
  parse_comments();

  open my $OUT, '>', $output_file;

  my $code_generated = 0;
  my $params = $types{$params_type};
  if(defined($params) && $$params->check_tree())
  {
    $code_generated = code_gen::print_code($OUT, $$params, $input_file, $version, $params_type);
  }

  if(!$code_generated)
  {
    print STDERR "error: can't generate introspection data for type `$params_type'.\n";
    code_gen::print_fallback($OUT, $input_file, $version, $params_type);
  }

  close $OUT;
}
else
{
  # copy input_file to output_file as a last resort. no introspection then
  copy($input_file, $output_file);
}

################# some debug functions #################

# sub dump_tokens
# {
#   while()
#   {
#     my @token = get_token();
#     last if($token[$P_TYPE] == $T_NONE);
#     print $token[0]." : ".$token[1]." : ".$token[2]."\n";
#   }
# }

# sub dump_comments
# {
#   my $lineno = 0;
#   foreach(@comments)
#   {
#     if(defined($_))
#     {
#       print "$lineno:\n";
#       my %line = %{$_};
#       foreach(@{$line{raw}})
#       {
#         print "  ".$_."\n";
#       }
#     }
#     $lineno++;
#   }
# }

# modelines: These editor modelines have been set for all relevant files by tools/update_modelines.sh
# vim: shiftwidth=2 expandtab tabstop=2 cindent
# kate: tab-indents: off; indent-width 2; replace-tabs on; indent-mode cstyle; remove-trailing-space on;
