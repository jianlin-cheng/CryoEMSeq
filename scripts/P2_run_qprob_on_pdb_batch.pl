#!/usr/bin/perl -w

use Cwd 'abs_path';
use File::Basename;
# /storage/htc/bdm/Collaboration/jh7x3/frag/scripts/P2_run_qprob_on_pdb_batch.pl /storage/htc/bdm/Collaboration/jh7x3/frag/result/frag1/  /storage/htc/bdm/Collaboration/jh7x3/frag/tools/ /storage/htc/bdm/Collaboration/jh7x3/frag/result/frag1.dfire_summary


$numArgs = @ARGV;
if($numArgs != 4)
{   
	print "the number of parameters is not correct!\n";
	exit(1);
}

$pdb_dir	= abs_path($ARGV[0]);  # 
$tool_dir	= "$ARGV[1]"; #/storage/htc/bdm/Collaboration/jh7x3/frag/tools
$scoreout	= "$ARGV[2]"; #

$script_dir = abs_path(dirname($0));
$pulchar_program = "$tool_dir/pulchra304/pulchra";
$scwrl4_program = "$tool_dir/scwrl4/Scwrl4";


if(!(-e $pulchar_program))
{
  die "Failed to find $pulchar_program\n";
}

if(!(-e $scwrl4_program))
{
  die "Failed to find $scwrl4_program\n";
}

if(!(-e "$tool_dir/qprob_package/bin/Qprob.sh"))
{
  die "Failed to find $tool_dir/qprob_package/bin/Qprob.sh\n";
}


opendir(DIR,"$pdb_dir") || die "failed to open directory $pdb_dir\n";

@files = readdir(DIR);

closedir(DIR);

%pdb2dfire=();

foreach $file (sort @files)
{

  if($file eq '.' or $file eq '..' or index($file,'.pdb')<0 or index($file,'scwrl')>0 or index($file,'rebuilt')>0)
  {
    next;
  }
  
  $pdbfile = "$pdb_dir/$file";
  
  if(index($pdbfile,'/')>=0)
  {
    @tmp = split(/\//,$pdbfile);
    $idname = pop @tmp;
    $filepath = join('/',@tmp);
  }
  if(index($idname,'.pdb')>0)
  {
    $idname = substr($idname,0,index($idname,'.pdb'));
  }
  
  #### run pulchar on pdb file 
  #print "$pulchar_program $pdbfile\n";
  `$pulchar_program $pdbfile`;
  if(!(-e "$filepath/$idname.rebuilt.pdb"))
  {
    die "The $filepath/$idname.rebuilt.pdb failed to be genearted\n";
  }
  
  #### run scwrl on pdb file 
  
  #print "$scwrl4_program -i $filepath/$idname.rebuilt.pdb -o $filepath/$idname.rebuilt.scwrl.pdb\n";
  `$scwrl4_program -i $filepath/$idname.rebuilt.pdb -o $filepath/$idname.rebuilt.scwrl.pdb`;
  if(!(-e "$filepath/$idname.rebuilt.scwrl.pdb"))
  {
    die "The $filepath/$idname.rebuilt.scwrl.pdb failed to be genearted\n";
  }
  
  #### run qprob on pdb file 
  if(!(-e "$pdb_dir/${idname}_qprob/$idname.Qprob_score"))
  {
		`mkdir $pdb_dir/${idname}_qprob`;
		`cp $filepath/$idname.rebuilt.scwrl.pdb $filepath/${idname}_qprob/${idname}_scwrl.pdb`; 
		chdir("$pdb_dir/${idname}_qprob");
		`perl $script_dir/pdb2fasta.pl $pdb_dir/${idname}_qprob/${idname}_scwrl.pdb $pdb_dir/${idname}_qprob/$idname $idname.fasta`;

		`mkdir models`;
		`cp $pdb_dir/${idname}_qprob/${idname}_scwrl.pdb models`;
		print "$tool_dir/qprob_package/bin/Qprob.sh $pdb_dir/${idname}_qprob/$idname.fasta   $pdb_dir/${idname}_qprob/models  $pdb_dir/${idname}_qprob/ &> $pdb_dir/${idname}_qprob/run.log\n";
		`$tool_dir/qprob_package/bin/Qprob.sh $pdb_dir/${idname}_qprob/$idname.fasta   $pdb_dir/${idname}_qprob/models  $pdb_dir/${idname}_qprob/ &> $pdb_dir/${idname}_qprob/run.log`;

  }else{
	print "$pdb_dir/${idname}_qprob/$idname.Qprob_score already generated\n";
  }
  
	


  if(!(-e "$pdb_dir/${idname}_qprob/$idname.Qprob_score"))
  {
    die "The $pdb_dir/${idname}_qprob/$idname.Qprob_score failed to be genearted\n";
  }
  
  $qprob_score=10000;  #initialize
  open(RWPLUS_CHECK, "$pdb_dir/${idname}_qprob/$idname.Qprob_score") || print "Can't open qprob output file.\n";
  while(<RWPLUS_CHECK>)
  {
      $line = $_;
      $line =~ s/\n//;
    @tem_split=split(/\s+/,$line);
    $qprob_score=$tem_split[1];
  }
  close RWPLUS_CHECK;
  
  print "qprob score of $idname: $qprob_score\n";
  $pdb2dfire{$file} =  $qprob_score;
  `rm $filepath/$idname.rebuilt.pdb`;
  `rm $filepath/$idname.rebuilt.scwrl.pdb`;
}


open(OUT,">$scoreout") || die "Failed to open file $scoreout\n";
foreach $model (sort {$pdb2dfire{$b} <=> $pdb2dfire{$a}} keys %pdb2dfire)
{
  print OUT "$model\t".$pdb2dfire{$model}."\n";
}
close OUT;
