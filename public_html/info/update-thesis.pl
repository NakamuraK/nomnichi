#!/usr/bin/perl
#
#
# $Id: index.cgi,v 1.1 2000/02/28 08:39:58 noguchi Exp noguchi $
# mkindex.pl -- Make HTML Form Index from Directory Entory part 2
# update by kawahara
# update by yusuke 2006-02-10 index.cgiñ�Τ�HTML���Ǥ��褦���ѹ�
# update by ogasawara & takiguchi 2007-02-22 ���פ����õ���Ԥ��ɤ���
# update by yusuke 2008-04-28 /lab/tani �ʲ��˰�ư������ŪHTML���Ǥ��褦�˽���
# update by kurihara 2009-04-41 /lab/nom/info �ʲ��˥��ԡ�����ǵ¼���Ѥ�´�ȡ���λ��ʸ�Υڡ������������褦���ѹ�
# update by ushio 2010-02-16 ��������������� 
use File::Basename;

$BaseDir = "DB/thesis";
$MemberListFile = "$BaseDir/member.list.euc";
$ICONSDIR = "./icons/";
$year = 0;
$jthesis = "����ʸ��";
$jabst = "��ͽ�ơ�";
$FIND = "/usr/bin/find $BaseDir \\( -name '*.ps' -o -name '*.pdf' \\) -print ";
@DEGREE = ('bachelor', 'master', 'doctor');
%JDEGREE = ('bachelor' => '´����ʸ', 
	    'master' => '������ʸ',
	    'doctor' => '�����ʸ');
%ICONPARAM = ('width' => 20, 'height' => 22);
@FindResult = ();
@MEMBERLIST = ();

sub PrintHeader;
sub PrintFooter;
sub PrintLink($$$);
sub GetMemberList;

# Main Routine

%MEMBERS = GetMemberList

PrintHeader;

@FindResult = `$FIND | sort`;
chomp @FindResult;


foreach $degree (@DEGREE) {
  print "<hr size=2>\n";
  $jdegree = "<font size=\"+2\">$JDEGREE{$degree}</font><br>\n";
  print $jdegree;

  print  "<table>","\n";
  foreach $mem (@MEMBERLIST) {
    unless ($MEMBERS{$mem}->{$degree._finish} == $year) {
	# Ʊ��ǯ�٤�ʣ��ɽ�����������ؤΤ�äĤ��н� by yusuke
    unless ($MEMBERS{$mem}->{$degree._finish} == '') {
      print "<tr>","\n";
      print "<td colspan=5><font size=\"+2\">$MEMBERS{$mem}->{$degree._finish}</font></td>";
      print "</tr>","\n";
      $year = $MEMBERS{$mem}->{$degree._finish};
	}
    }
    if ($MEMBERS{$mem}->{$degree._title}) {
      print "<tr>","\n";
      $title = "��".$MEMBERS{$mem}->{$degree._title}."��";
      $title =~ s!Tender!<font size="+1"><b><i>Tender</i></b></font> !g;
      $title =~ s!AnT!<font size="+1"><b><i>AnT</i></b></font> !g;
      print "<td>$title</td>\n";  
      $name = "(".$MEMBERS{$mem}->{"name"}.")";
      print "<td nowrap>$name</td>\n";
      print "<td nowrap>$jthesis</td>\n";
#      PrintLink($mem, $degree, @FindResult);
      PrintLink($mem, $degree, 'thesis');
      print "</tr>","\n";

      $file1 = "$BaseDir/$mem/$degree/abstract.ps";
      $file2 = "$BaseDir/$mem/$degree/abstract.pdf";
      if (-e $file1 || -e $file2) {
        print "<tr>","\n";
        print "<td></td>";
        print "<td></td>";
        print "<td>$jabst</td>";
        PrintLink($mem, $degree, 'abstract');
        print "</tr>","\n";
      }
    }
  }
  print "</table>","\n";
}

PrintFooter;

exit 0;

### Sub Routine

sub PrintHeader {
	my $htmlheader;
	$htmlheader = <<HTMLHEADER;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<html>
  <head>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
    <title>ǵ¼���漼 ´��/��λ ��ʸ����</title>
  </head>
  <body bgcolor="white" text="black" link="blue" alink="#FFFFCC" vlink="#FF88FF">
<h1>ǵ¼���漼 ´��/��λ ��ʸ����</h1>
<br>
<a href="index.html">�ȥåפ�</a><br>
<!--<a href="$BaseDir/index2.cgi">ǵ¼���漼 ´��/��λ ��ʸ�����������̡�</a><br>-->
<a href="$BaseDir/README">�ǡ������ɲ���ˡ</a>
HTMLHEADER

	print $htmlheader;
}

sub PrintLink($$$) {
  my ($name, $degree, $filetype) = @_;
  my @SUFFIX = ("ps", "pdf");
  my ($basename, $dir, $ext);
  my $icon;

  foreach $suffix (@SUFFIX) {
    my $file;
    $file = "$BaseDir/$name/$degree/$filetype.$suffix";
    if (-e $file) {
      $icon = $ICONSDIR.$suffix.".png";
      print "<td nowrap>";
      print "<a href=\"$BaseDir/$name/$degree/$filetype.$suffix\">";
      print uc $suffix, " FILE";
      print "<img src=\"$icon\" align=\"middle\" width=$ICONPARAM{'width'} height=$ICONPARAM{'height'} border=0 alt=\"$name $degree $suffix\">";
      print "</a>";
      print "</td>\n";
    }
    else {
      print "<td></td>\n";
    }
  }
  1;
}

sub PrintFooter {
  my $footer;
  $footer = <<HTMLFOOTER;
<hr size=2>
<em>Nomura Lab.</em>
  </body>
</html>
HTMLFOOTER

  print $footer;
}

sub GetMemberList {
	open(MEMBERFILE, $MemberListFile) || die "Can not open $MemberListFile .";
	while(<MEMBERFILE>) {
		next if (/^\#/);
		chomp;

		($dirname, $name, $b_finish, $b_title, $m_finish, $m_title, $d_finish, $d_title) = split(/,/,$_, -1);
		push(@MEMBERLIST, $dirname);
		$MEMBERS{$dirname} = {"name" => $name,
			"bachelor_finish" => $b_finish,
			"bachelor_title" => $b_title,
			"master_finish" => $m_finish,
			"master_title" => $m_title,
			"doctor_finish" => $d_finish,
			"doctor_title" => $d_title
		}
	}
	close(MEMBERFILE);
	return %MEMBERS;
}

