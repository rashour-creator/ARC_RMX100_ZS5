#!/usr/bin/perl -w

if ($#ARGV < 0) {
   die("Not enough arguments\n");
}

$input  = $ARGV[0];
$output = $ARGV[0];

$output =~ s/\.hex/\.cde/;

open(IN, "<$input")   || die "Can not open file for reading";
open(OUT, ">$output") || die "Can not create file for writing";


$addr_curr = -1;

while (<IN>) {
   @words = split;
   
   if ($words[0] =~ /-/)
   {
      @range = split (/-/, $words[0]);
      $from  = hex($range[0]); 
      $to    = hex($range[1]); 
      
      $addr_gap = ($from) - ($addr_curr);
      
      if ($addr_gap != 1) {
         print (OUT "\@$range[0]\n"); 
      }

      for ($count = $from; $count <= $to; $count++) {
         print (OUT "$words[2]\n");
      }
      
      $addr_curr = $to;
   } 
   else
   {
      
      $addr_gap  = hex($words[0]) - ($addr_curr);
      if ($addr_gap != 1) {
         print (OUT "\@$words[0]\n"); 
      }
      
      # only output address if it  is different than the previous one
      if ($addr_gap != 0) {
         print (OUT "$words[2]\n"); 
      }
      
      $addr_curr = hex($words[0]);
   }  
}

close (IN);                
close (OUT);               
close (ZERO);
close (ONE);

print "Conversion done. Output file: $output\n"; 

#KK: @@@ 3-Apr-2011

$cdefile = $output;
$cdefile =~ s/.cde//;

open (IN, "<${cdefile}.cde")      || die "Can not open file for reading";
open (ZERO,  ">${cdefile}_0.cde") || die "Can not create file for writing"; 
open (ONE,   ">${cdefile}_1.cde") || die "Can not create file for writing"; 

while (<IN>)
{
   if (/^@[23]/)
   {  
     print (ONE "$_");
     $second = 1;
   }
   elsif (/^@[01]/)
   {  
     print (ZERO "$_");
     $second = 0;
   }
   else
   {
     if ($second)
     {  print (ONE "$_");   }
     else
     {  print (ZERO "$_");  }
   }
}

close (IN);
close (ZERO);
close (ONE);
exit;


# KK 28-Sep-2010 @@@
# break the hex file into 4 parts - byte
# temporary workaround until VCS can load hex file into 4GB array using $readmemh

$cdefile = $output;
$cdefile =~ s/.cde//;

open (IN, "<${cdefile}.cde")      || die "Can not open file for reading";
open (ZERO,  ">${cdefile}_0.cde") || die "Can not create file for writing"; 
open (ONE,   ">${cdefile}_1.cde") || die "Can not create file for writing"; 
open (TWO,   ">${cdefile}_2.cde") || die "Can not create file for writing"; 
open (THREE, ">${cdefile}_3.cde") || die "Can not create file for writing"; 

while (<IN>)
{
   if (/^@/)
   {
      print (ZERO "$_");
      print (ONE "$_");
      print (TWO "$_");
      print (THREE "$_");
   }
   else
   {
      @byt = split(//);
      print (THREE "$byt[0]$byt[1]\n");
      print (TWO   "$byt[2]$byt[3]\n");
      print (ONE   "$byt[4]$byt[5]\n");
      print (ZERO  "$byt[6]$byt[7]\n");
   }

}

close (IN);
close (ZERO);
close (ONE);
close (TWO);
close (THREE);
