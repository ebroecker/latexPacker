#!/usr/bin/perl
use strict;
use Archive::Zip;


if ($#ARGV != 0)
{
  print "Usage: texZip mainDocument\n\n";
  print "Example: texZip main.tex\n\t(main.log must exist!)";
  exit();
}

my $texFile = shift;
my $zip = Archive::Zip->new();
my $date = sprintf("%04d-%02d-%02d",((localtime)[5]+ 1900),((localtime)[4] +1),(localtime)[3]);

$texFile =~ s/\.tex//;
$texFile =~ s/\.log//;
if(!open(FILE,"<$texFile.log"))
{
  print "Error opening $texFile.log\n";
  exit(1);
}

while(my $line = <FILE>)
{
  my @tokens = split (/\)|\>/, $line);
  
  foreach my $token (@tokens)
  {
    if($token =~ /\(\"(.*)\"\Z/)
    {
      my $file = $1;
      if(-e $1)
      {
        my $clearName =   &clearPath($file);
        $zip->addFile( $file, $clearName );
      }
    }
    elsif($token =~ /\((.*)\Z/ || $token =~ /\<(.*)\Z/)
    {
      my $file = $1;
      if(-e $1)
      {
        $zip->addFile( $file );
      }
    }
  }
}

$zip->writeToFileNamed($date . "_" . $texFile . ".zip");

sub clearPath {
  my $filename = shift;
  
  $filename =~ s/.*\///;
  $filename =~ s/.*\\//;
  
  return $filename;
}