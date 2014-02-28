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

package scanner;

use strict;
use warnings;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw( @token @comments
                  $P_LINENO $P_FILENAME $P_TYPE $P_VALUE
                  $T_NONE $T_IDENT $T_KEYWORD $T_INTEGER_LITERAL $T_OPERATOR
                  $K_UNSIGNED $K_SIGNED $K_GBOOLEAN $K_CHAR $K_SHORT $K_INT $K_UINT $K_LONG $K_FLOAT $K_DOUBLE $K_TYPEDEF $K_STRUCT $K_UNION $K_CONST $K_VOLATILE $K_STATIC $K_ENUM $K_VOID $K_DT_MODULE_INTROSPECTION
                  $O_ASTERISK $O_AMPERSAND $O_SEMICOLON $O_COMMA $O_COLON $O_SLASH $O_LEFTROUND $O_RIGHTROUND $O_LEFTCURLY $O_RIGHTCURLY $O_LEFTSQUARE $O_RIGHTSQUARE $O_EQUAL
                  read_file get_token look_ahead token2string
                  isid isinteger issemicolon istypedef isstruct isunion isenum isleftcurly isrightcurly isleftround isrightround isleftsquare isrightsquare 
                  iscomma isasterisk isequal isconst isvolatile isdtmoduleintrospection
                );


################# the scanner #################

my $lineno = 1;
my $file;
my @tokens;
our @token;
our @comments;

my @code;
my $code_ptr = 0;

# parser layout
our $P_LINENO = 0;
our $P_FILENAME = 1;
our $P_TYPE = 2;
our $P_VALUE = 3;

my $i = 0;
# token types
our $T_NONE = $i++;
our $T_IDENT = $i++;
our $T_KEYWORD = $i++;
our $T_INTEGER_LITERAL = $i++;
our $T_OPERATOR = $i++;

$i = 0;
# keywords
my  @K_readable;
our $K_UNSIGNED = $i++; push(@K_readable, 'unsigned');
our $K_SIGNED = $i++; push(@K_readable, 'signed');
our $K_GBOOLEAN = $i++; push(@K_readable, 'gboolean');
our $K_CHAR = $i++; push(@K_readable, 'char');
our $K_SHORT = $i++; push(@K_readable, 'short');
our $K_INT = $i++; push(@K_readable, 'int');
our $K_UINT = $i++; push(@K_readable, 'uint');
our $K_LONG = $i++; push(@K_readable, 'long');
our $K_FLOAT = $i++; push(@K_readable, 'float');
our $K_DOUBLE = $i++; push(@K_readable, 'double');
our $K_TYPEDEF = $i++; push(@K_readable, 'typedef');
our $K_STRUCT = $i++; push(@K_readable, 'struct');
our $K_UNION = $i++; push(@K_readable, 'union');
our $K_CONST = $i++; push(@K_readable, 'const');
our $K_VOLATILE = $i++; push(@K_readable, 'volatile');
our $K_STATIC = $i++; push(@K_readable, 'static');
our $K_ENUM = $i++; push(@K_readable, 'enum');
our $K_VOID = $i++; push(@K_readable, 'void');
our $K_DT_MODULE_INTROSPECTION = $i++; push(@K_readable, 'DT_MODULE_INTROSPECTION');
my  @keywords = (
      ['unsigned', $K_UNSIGNED],
      ['signed', $K_SIGNED],
      ['gboolean', $K_GBOOLEAN],
      ['char', $K_CHAR],
      ['gchar', $K_CHAR],
      ['short', $K_SHORT],
      ['int', $K_INT],
      ['gint', $K_INT],
      ['uint', $K_UINT],
      ['uint32_t', $K_UINT],
      ['int32_t', $K_INT],
      ['long', $K_LONG],
      ['float', $K_FLOAT],
      ['double', $K_DOUBLE],
      ['typedef', $K_TYPEDEF],
      ['struct', $K_STRUCT],
      ['union', $K_UNION],
      ['const', $K_CONST],
      ['volatile', $K_VOLATILE],
      ['static', $K_STATIC],
      ['enum', $K_ENUM],
      ['void', $K_VOID],
      ['DT_MODULE_INTROSPECTION', $K_DT_MODULE_INTROSPECTION]
);

$i = 0;
# operators
my  @O_readable;
our $O_ASTERISK = $i++; push(@O_readable, '*');
our $O_AMPERSAND = $i++; push(@O_readable, '&');
our $O_SEMICOLON = $i++; push(@O_readable, ';');
our $O_COMMA = $i++; push(@O_readable, ',');
our $O_COLON = $i++; push(@O_readable, ':');
our $O_SLASH = $i++; push(@O_readable, '/');
our $O_LEFTROUND = $i++; push(@O_readable, '(');
our $O_RIGHTROUND = $i++; push(@O_readable, ')');
our $O_LEFTCURLY = $i++; push(@O_readable, '{');
our $O_RIGHTCURLY = $i++; push(@O_readable, '}');
our $O_LEFTSQUARE = $i++; push(@O_readable, '[');
our $O_RIGHTSQUARE = $i++; push(@O_readable, ']');
our $O_EQUAL = $i++; push(@O_readable, '=');

sub read_file
{
  $file = shift;
  open(IN, "<$file");
  my @tmp = <IN>;
  close(IN);
  my $result = join('', @tmp);
  @code = split(//, $result);
}

# TODO: support something else than decimal numbers, i.e., octal and hex
sub read_number
{
  my $c = shift;
  my $start = $code_ptr;
  my @buf;
  while($c =~ /[0-9]/)
  {
    push(@buf, $c);
    $start++;
    $c = $code[$start];
  }
  return join('', @buf);
}

sub read_string
{
  my $c = shift;
  my $start = $code_ptr;
  my @buf;
  while($c =~ /[a-zA-Z_0-9]/)
  {
    push(@buf, $c);
    $start++;
    $c = $code[$start];
  }
  return join('', @buf);
}

sub handle_comment
{
  my $_lineno = $lineno;
  my $c = $code[$code_ptr];
  my $start = $code_ptr;
  my @buf;
  if($c eq '/')
  {
    # a comment of the form '//'. this goes till the end of the line
    while(defined($c) && $c ne "\n")
    {
      push(@buf, $c);
      $start++;
      $c = $code[$start];
    }
    $lineno++;
  }
  elsif($c eq '*')
  {
    # a comment of the form '/*'. this goes till we find '*/'
    while(defined($c) && ($c ne '*' || $code[$start+1] ne '/'))
    {
      $lineno++ if($c eq "\n");
      push(@buf, $c);
      $start++;
      $c = $code[$start];
    }
    push(@buf, $c);
  }
  else
  {
    print "comment error\n";
  }
  my $comment = join('', @buf);

  if(defined($comments[$_lineno]))
  {
    push($comments[$_lineno]{raw}, $comment);
  }
  else
  {
    $comments[$_lineno]{raw}[0] = $comment;
  }

  return length($comment);
}

sub read_token
{
  for(; defined($code[$code_ptr]); $code_ptr++)
  {
    my $c = $code[$code_ptr];
    if($c eq "\n") { ++$lineno;}
    elsif($c eq " " || $c eq "\t") { next; }
    elsif($c eq "&") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_AMPERSAND); }
    elsif($c eq "*") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_ASTERISK); }
    elsif($c eq "/" && ($code[$code_ptr+1] eq "/" || $code[$code_ptr+1] eq "*" ))
    {
      $code_ptr++;
      $code_ptr += handle_comment();
      next;
    }
    elsif($c eq ";") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_SEMICOLON); }
    elsif($c eq ",") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_COMMA); }
    elsif($c eq "(") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_LEFTROUND); }
    elsif($c eq ")") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_RIGHTROUND); }
    elsif($c eq "{") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_LEFTCURLY); }
    elsif($c eq "}") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_RIGHTCURLY); }
    elsif($c eq "[") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_LEFTSQUARE); }
    elsif($c eq "]") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_RIGHTSQUARE); }
    elsif($c eq ":") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_COLON); }
    elsif($c eq "=") { ++$code_ptr; return ($lineno, $file, $T_OPERATOR, $O_EQUAL); }
    elsif($c =~ /[0-9]/)
    {
      my $number = read_number($c);
      $code_ptr += length($number);
      return ($lineno, $file, $T_INTEGER_LITERAL, $number);
    }
    elsif($c =~ /[a-zA-Z_]/)
    {
      my $string = read_string($c);
      $code_ptr += length($string);
      foreach(@keywords)
      {
        my @entry = @{$_};
        if($string eq $entry[0])
        {
          return ($lineno, $file, $T_KEYWORD, $entry[1]);
        }
      }
      return ($lineno, $file, $T_IDENT, "$string");
    }
    else {
      # we don't care that we can't understand every input symbol, we just read over them until we reach something we know.
      # everything we see from there on should be handled by the scanner/parser
      # print "scanner error: ".$c."\n";
    }
  }
  return ($lineno, $file, $T_NONE, 0);
}

sub get_token
{
  my $n_tokens = @tokens;
  return read_token() if($n_tokens == 0);
  return @{shift(@tokens)};
}

sub look_ahead
{
  my $steps = shift;
  my $n_tokens = @tokens;

  return $tokens[$steps-1] if($n_tokens >= $steps);

  my @token;
  for(my $i = $n_tokens; $i < $steps; ++$i )
  {
    @token = read_token();
    return @token if($token[$P_TYPE] == $T_NONE);              # Can't look ahead that far.
    push(@tokens, [@token]);
  }
  return @token;
}

sub token2string
{
  my $token = shift;
  my $result;

  if   ($token[$P_TYPE] == $T_NONE)            { $result = '<EMPTY TOKEN>'; }
  elsif($token[$P_TYPE] == $T_IDENT)           { $result = $token[$P_VALUE]; }
  elsif($token[$P_TYPE] == $T_KEYWORD)         { $result = $K_readable[$token[$P_VALUE]]; }
  elsif($token[$P_TYPE] == $T_INTEGER_LITERAL) { $result = $token[$P_VALUE]; }
  elsif($token[$P_TYPE] == $T_OPERATOR)        { $result = $O_readable[$token[$P_VALUE]]; }
  else                                         { $result = '<UNKNOWN TOKEN TYPE>'; }

  return $result;
}

sub issemicolon { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_SEMICOLON); }
sub isleftcurly { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_LEFTCURLY); }
sub isrightcurly { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_RIGHTCURLY); }
sub isleftround { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_LEFTROUND); }
sub isrightround { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_RIGHTROUND); }
sub isleftsquare { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_LEFTSQUARE); }
sub isrightsquare { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_RIGHTSQUARE); }
sub iscomma { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_COMMA); }
sub isasterisk { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_ASTERISK); }
sub isequal { my $token = shift; return ($token[$P_TYPE] == $T_OPERATOR && $token[$P_VALUE] == $O_EQUAL); }
sub isid { my $token = shift; return ($token[$P_TYPE] == $T_IDENT); }
sub isinteger { my $token = shift; return ($token[$P_TYPE] == $T_INTEGER_LITERAL); }
sub istypedef { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_TYPEDEF); }
sub isstruct { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_STRUCT); }
sub isunion { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_UNION); }
sub isenum { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_ENUM); }
sub isconst { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_CONST); }
sub isvolatile { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_VOLATILE); }
sub isdtmoduleintrospection { my $token = shift; return ($token[$P_TYPE] == $T_KEYWORD && $token[$P_VALUE] == $K_DT_MODULE_INTROSPECTION); }

1;

# modelines: These editor modelines have been set for all relevant files by tools/update_modelines.sh
# vim: shiftwidth=2 expandtab tabstop=2 cindent
# kate: tab-indents: off; indent-width 2; replace-tabs on; indent-mode cstyle; remove-trailing-space on;
