#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Bio::SeqIO;
my %snppos=();
my %ref=();

my $options = check_params();
my $out_file = $options->{'i'}.".nc";

 open my $snp_fh, '<', $options->{'i'}
   or die("Can't open snp file [$options->{'i'}]: $!.\n");





	while(my $line = <$snp_fh>){
		chomp($line);
		next if($line=~/^#/);
		(my @elements)=split(/\t/, $line);
		$snppos{$elements[0]}{$elements[1]}++;
	}


get_seq_length();
snp2nc();






sub snp2nc{
	my ($length) = @_;
 for my $chr (keys %ref){
   open my $out_fh, '>', $chr.".nc"
   or die("Can't open out file [$chr.nc]: $!.\n");
  for(my $pos=1;$pos <= $ref{$chr}; $pos++){
   if(exists $snppos{$chr}{$pos}){
    print $out_fh "1\n";
   }else{
    print $out_fh "0\n";
   }
  }
 }
}



sub get_seq_length{
	my $len;
	my $seqIN = Bio::SeqIO->new( '-format' => 'fasta', '-file' => "$options->{'ref'}" );

        while ( my $fasta_obj = $seqIN->next_seq() ) {
                my $id     = $fasta_obj->display_id();
                $len = $fasta_obj->length();
                $ref{$id}=$len;
        }
	#return(%ref);
}





sub check_params {
	my @standard_options = ( "help+", "man+" );
	my %options;

	# Add any other command line options, and the code to handle them
	GetOptions( \%options, @standard_options, "i:s", "ref:s");
	exec("pod2usage $0") if $options{'help'};
	exec("perldoc $0")   if $options{'man'};
	exec("pod2usage $0") if !( $options{'i'} && $options{'ref'} );

	return \%options;
}

__DATA__

=head1 NAME

    snp2nc.pl
   
=head1 DESCRIPTION

		Convert SNP positions to nc format

=head1 SYNOPSIS

    snp2nc.pl <snp file> [<ref file> ...]
    
    
	-i <input file>             SNP positions
	-ref <input file>			Ref in fasta format
    
    Example:

		perl snp2nc.pl -i snp_pos.txt -ref chrom1.fasta
    
      
=cut
