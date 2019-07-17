#!/usr/bin/perl -w

##########################################################################
# Extract fasta from PDB model with specified input
#
# 2 arguments
# Output:   fasta file from pdb model
# run: perl pdb2fasta.pl <pdb file> <pdb name> <fasta outfile>
# Example :  perl pdb2fasta.pl domain0.atom domain0 domain0.fasta  
#                         
# Author: Jie Hou
# Date: 05/11/2016
##########################################################################

use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;

$num = @ARGV;
if($num != 3)
{
	die  "The number of parameter is not correct!\n";
}

$file_PDB = $ARGV[0];
$domain_name = $ARGV[1];
$fasta_out = $ARGV[2];

#print "\n**************************************************\n";
#print "run pdb2fasta.pl on $domain_name\n";

open SEQUENCE, ">$fasta_out" or die "Failed to open $fasta_out\n";

my $seq = "";
open(INPUTPDB, "$file_PDB") || die "ERROR! Could not open $file_PDB\n";
while(<INPUTPDB>){
	next if $_ !~ m/^ATOM/;
	next unless (parse_pdb_row($_,"aname") eq "CA");
	confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $file_PDB! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
	my $res = $AA3TO1{parse_pdb_row($_,"rname")};
	$seq .= $res;
}
close INPUTPDB;
if (length($seq) < 1){
	print "WARNING! $file_PDB has less than 1 residue ($seq)!\n";
}
print SEQUENCE ">$domain_name\n$seq\n";

close SEQUENCE;

sub parse_pdb_row{
	my $row = shift;
	my $param = shift;
	my $result;
	$result = substr($row,6,5) if ($param eq "anum");
	$result = substr($row,12,4) if ($param eq "aname");
	$result = substr($row,16,1) if ($param eq "altloc");
	$result = substr($row,17,3) if ($param eq "rname");
	$result = substr($row,22,5) if ($param eq "rnum");
	$result = substr($row,21,1) if ($param eq "chain");
	$result = substr($row,30,8) if ($param eq "x");
	$result = substr($row,38,8) if ($param eq "y");
	$result = substr($row,46,8) if ($param eq "z");
	print "Invalid row[$row] or parameter[$param]" if (not defined $result);
	$result =~ s/\s+//g;
	return $result;
}