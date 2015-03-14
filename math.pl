#行列関係関数
#matrixTest();
sub matrixTest{
#	@a=([1,1,1,1],[1,-1,-1,1],[1,1,-1,-1],[1,-1,1,-1]);
#	@b=([1,1,1,1],[1,-1,1,-1],[1,1,-1,-1],[1,-1,-1,1]);
#	@a=([1,1],[1,-1]);
#	@b=([c_0],[c_1]);
#	@a=([1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]);
#	@b=@a;
	@a=([0,"-i"],["i",0]);
	@b=@a;
	@r=matrixMul(\@a,\@b);
	@a=([0,"-i"],["i",0]);
	@r=matrixMul(\@r,\@a);
	print matrix2Text(\@r);
	saveFile("./out.tex",matrix2Tex(\@r));
	}

sub matrixTemplate{
	my @arg=@_;
	my @m0=@{$arg[0]};
	my @m1=@{$arg[1]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	my @r;
	
	my $m1y=@m1;
	my $m1x=@{$m1[0]};
	
}

sub matrixSize{
	my @arg=@_;
	my @m0=@{$arg[0]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	
	return ($m0x,$m0y);
}

sub matrix2Tex{
	my @arg=@_;
	my @m0=@{$arg[0]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	
	my $r="";
	for(my $i=0;$i<$m0y;$i++){
		for(my $j=0;$j<$m0x-1;$j++){
			$r.=$m0[$i][$j]."&";
		}
		$r.=$m0[$i][$m0x-1]."\\\\\n";
	}
	return "\\left(\n\\begin{array}{".("c" x $m0x )."}\n".$r."\\end{array}\n\\right)\n";
}

sub matrix2Text{
	my @arg=@_;
	my @m0=@{$arg[0]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	
	my $r="";
	for(my $i=0;$i<$m0y;$i++){
		for(my $j=0;$j<$m0x-1;$j++){
			$r.=$m0[$i][$j]." ";
		}
		$r.=$m0[$i][$m0x-1]."\n";
	}
	return $r;
}


sub matrixAdd{
	my @arg=@_;
	my @m0=@{$arg[0]};
	my @m1=@{$arg[1]};
	#入力行列m0は([a11,a12],[a21,a22])といった順番。a23へはa[1][2]でアクセスする。
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	my @r;
	#行列@m0は$m0y*$m0x行列。順番に注意。
	
	my $m1y=@m1;
	my $m1x=@{$m1[0]};
	
	if($m0x == $m1x and $m0y == $m1y){
		for(my $i=0;$i<$m0y;$i++){
			for(my $j=0;$j<$m0x;$j++){
				$r[$i][$j]=formulaAddTex($m0[$i][$j],$m1[$i][$j]);
#				$r[$i][$j]=$m0[$i][$j]+$m1[$i][$j];
			}
		}
	}else{return 0;}
	return @r;
}


sub matrixSub{
	my @arg=@_;
	my @m0=@{$arg[0]};
	my @m1=@{$arg[1]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	my @r;
	
	my $m1y=@m1;
	my $m1x=@{$m1[0]};
	
	if($m0x == $m1x and $m0y == $m1y){
		for(my $i=0;$i<$m0y;$i++){
			for(my $j=0;$j<$m0x;$j++){
				$r[$i][$j]=$m0[$i][$j]-$m1[$i][$j];
				#TODO:式の引き算対応
			}
		}
	}else{return 0;}
	return @r;
}

sub matrixMul{
	my @arg=@_;
	my @m0=@{$arg[0]};
	my @m1=@{$arg[1]};
	
	my $m0y=@m0;
	my $m0x=@{$m0[0]};
	my @r;
	
	my $m1y=@m1;
	my $m1x=@{$m1[0]};
	
	if($m0x == $m1y){
		for(my $i=0;$i<$m0y;$i++){
			for(my $j=0;$j<$m1x;$j++){
				my $temp1="0";
				for(my $k=0;$k<$m0x;$k++){
					$temp1=formulaAddTex(formulaExpandTex($m0[$i][$k],$m1[$k][$j]),$temp1);
#					$temp1+=$m0[$i][$k]*$m1[$k][$j];
#print "A:".$m0[$i][$k]."*".$m1[$k][$j]."=".formulaExpandTex($m0[$i][$k],$m1[$k][$j])."\n";
				}
				$r[$i][$j]=$temp1;
			}
		}
	}else{return 0;}
	return @r;
}


#分数関係関数
sub fraction2Tex{
	my @a=@_;
	return "\\frac{$a[0]}{$a[1]}";
}

sub fraction2Text{
	my @a=@_;
	return "$a[0] / $a[1]";
}

sub fractionAdd{
	my @a=@_;
	#入力は(分子1,分母1,分子2,分母2)
	return ($a[0]*$a[3]+$a[1]*$a[2],$a[1]*$a[3]);
}

sub fractionSub{
	my @a=@_;
	return fractionAdd($a[0],$a[1],0-$a[2],$a[3]);
}

sub fractionMul{
	my @a=@_;
	return ($a[0]*$a[2],$a[1]*$a[3]);
}

sub fractionDiv{
	my @a=@_;
	return fractionMul($a[0],$a[1],$a[2],$a[3]);
}

sub fractionReduction{
	my @a=@_;
	for(my $i=2;$i<=sqrt($a[0]) or $i<=sqrt($a[1]);$i++){
		while($a[0]%$i==0 and $a[0]%$i==0){$a[0]/=$i;$a[1]/=$i;}
		}
	return @a;
}


#文字式演算関数

#TODO:式をまとめる(ex.abc+3bc=bc(a+3))関数。因数分解関数。わり算関数。全体をn乗。負数をかける。
#formulaTest();
sub formulaTest{
	$"=",";

	my @a=(1,2,3);
	my @b=(1,1);
	my @r=formulaExpandNumber(\@a,\@b);
#	print "@r\n";

#	print formulaTex2Hash("3 2 a^{abc}a^2b^4");
#	my %r=formulaTex2HashTerm("3a^2b^4");
#	my %p=formulaTex2HashTerm("2a^5b^1");
#	@a=(\%r,\%p);
#	@r=formulaExpandVar(\@a,\@a);
#	print formula2Tex(\@r);
	print formulaExpandTex("3^2a^2 b^3+4ab","2a^5b^3+c");
	print "\n";
	print "(3a^2+4ab+6) + (1+2ab+2a^4) = ";
	print formulaAddTex("3a^2+4ab-6","1+2ab+2a^4");
	}

sub formulaExpandTex{
	my @arg=@_;
	my @a=formulaTex2Hash($arg[0]);
	my @b=formulaTex2Hash($arg[1]);
	my @r=formulaExpandVar(\@a,\@b);
	return formula2Tex(\@r);
	}

sub formulaExpandNumber{
	my @arg=@_;
	my @f0=@{$arg[0]};
	my @f1=@{$arg[1]};
	my @r;
	
	for(my $i=0;$i<@f0+@f1-1;$i++){$r[$i]=0;}
	for(my $i=0;$i<@f0;$i++){
		for(my $j=0;$j<@f1;$j++){
			$r[$i+$j]+=$f0[$i]*$f1[$j];
			}
		}
	return @r;
	}

sub formulaExpandVar{
	my @arg=@_;
	#引数は(\@a,\@b)とし@a,@bはそれぞれ@a=(\%c,\%d);として定義され、%c,%dは、それぞれ%c=("変数文字"=>"その乗数");として与えられる。例えばx^2y^4+x^2+y^5なら%c=("x"=>"2","y"=>"4")となる。
	#加えて、その%c=("#NUMBER#"=>"数字")として、その項に係る数を表現できる。
	my @f0=@{$arg[0]};
	my @f1=@{$arg[1]};
	my @r;
	
	for(my $i=0;$i<@f0*@f1;$i++){$r[$i]=0;}
	for(my $i=0;$i<@f0;$i++){
		for(my $j=0;$j<@f1;$j++){
			my %t=%{$f0[$i]};
			while(my($k,$v)=each(%{$f1[$j]})){
				if($k=~ "#NUMBER#"){
					if(exists($t{$k})){
						$t{$k}*=$v;
						}else{
						$t{$k}=$v;
						}
					}elsif(!exists($t{$k})){
					$t{$k}=$v;
					}else{
					$t{$k}=formulaAddTex($v,$t{$k});
					}
				}
			$r[$i*(0+@f0)+$j]=\%t;
			}
		}
	return @r;
	#返り値は引数の説明での%c,%dと同じ形式。
	}

sub formulaTex2HashTerm{
	my $t=$_[0];
	my %r=("#NUMBER#",1);


	$t=~ s/^\-/%r=formulaTex2HashTermEach(\%r,"#NUMBER#",-1);""/eg;

	$t=~ s/(\\[a-zA-Z]+_\{[\\\w\^]+\})\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_\{[\\\w\^]+\})\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_\{[\\\w\^]+\})\^([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_\{[\\\w\^]+\})\^(\\[a-zA-Z_]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_\{[\\\w\^]+\})/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;

	$t=~ s/(\\[a-zA-Z]+_[\w])\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_[\w])\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_[\w])\^([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_[\w])\^(\\[a-zA-Z_]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+_[\w])/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;

	$t=~ s/(\\[a-zA-Z]+)\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+)\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+)\^([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+)\^(\\[a-zA-Z_]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/(\\[a-zA-Z]+)/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;

	$t=~ s/([a-zA-Z]_\{[\\\w\^]+\})\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_\{[\\\w\^]+\})\^([a-zA-Z]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_\{[\\\w\^]+\})\^([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_\{[\\\w\^]+\})\^(\\[a-zA-Z_]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_\{[\\\w\^]+\})/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;

	$t=~ s/([a-zA-Z]_[\w])\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_[\w])\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_[\w])\^([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_[\w])\^(\\[a-zA-Z_0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z]_[\w])/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;

	$t=~ s/([0-9]+)\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,"#NUMBER#",(($1)**$2));""/eg;

	$t=~ s/([0-9]+)\^([A-Za-z])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([0-9]+)\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;

	$t=~ s/([a-zA-Z])\^\{(\w+)\}/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z])\^([0-9]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);"";""/eg;
	$t=~ s/([a-zA-Z])\^([a-zA-Z0-9])/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z])\^(\\[a-zA-Z0-9_]+)/%r=formulaTex2HashTermEach(\%r,$1,$2);""/eg;
	$t=~ s/([a-zA-Z])/%r=formulaTex2HashTermEach(\%r,$1,1);""/eg;
	$t=~ s/([0-9]+)/%r=formulaTex2HashTermEach(\%r,"#NUMBER#",($1));""/eg;
	
#print "$t\n";
	#虚数処理
	if(exists($r{"i"})){$r{"i"}=($r{"i"})%4};
	if(exists($r{"i"}) and $r{"i"}>=2){$r{"#NUMBER#"}*=-1;};
	if(exists($r{"i"})){$r{"i"}=($r{"i"})%2};
	
	return %r;
	}

sub formulaTex2HashTermEach{
	my @a=@_;
	my %r=%{$a[0]};
	if($a[1] eq "#NUMBER#"){
		$r{$a[1]}*=$a[2];
		}elsif(exists($r{$a[1]})){
		$r{$a[1]}=formulaAddTex($a[2],$r{$a[1]});
		}elsif($a[2]ne"0"){
		$r{$a[1]}=$a[2];
		}
	$a[0]=\%r;
	return %r;
	}

sub formulaTermAdd{
	#与えられた二項が加算可能なら加算。できないならヌルハッシュを返す。
	my @a=@_;
	my %a=%{$a[0]};
	my %b=%{$a[1]};
	my ($n0,$n1);
	if(exists($a{"#NUMBER#"})){$n0=$a{"#NUMBER#"};delete($a{"#NUMBER#"});}else{$n0=1;}
	if(exists($b{"#NUMBER#"})){$n1=$b{"#NUMBER#"};delete($b{"#NUMBER#"});}else{$n1=1;}
	my $s=0;
	if(0+ keys(%a) !=0+ keys(%b)){$s=1;}
	while(my($k,$v)=each(%a)){
		if(!(exists($b{$k})and($b{$k} eq $v))){$s=1;last;}
		}
	if($s==1){my %c=();return %c;}else{
		$a{"#NUMBER#"}=$n0+$n1;
		return %a;
		}
	}

sub formulaAddTerm{
	#リスト形式の多項式に単項を追加。
	my @a=@{$_[0]};
	my %b=%{$_[1]};
	push(@a,\%b);
	for(my $i=0;$i<@a-1;$i++){
		my %c=formulaTermAdd(\%{$a[$i]},\%b);
		if(0+keys(%c)!=0){%{$a[$i]}=%c;pop(@a);last;}
		}
	return @a;
	}

sub formulaAdd{
	#多項式同士の可算。
	my @a=@{$_[0]};
	my @b=@{$_[1]};
	
	for(my $i=0;$i<@b;$i++){
		@a=formulaAddTerm(\@a,\%{$b[$i]});
		}
	return @a;
	}

sub formulaAddTex{
	my @a=@_;
	my @b=formulaTex2Hash($a[0]);
	my @c=formulaTex2Hash($a[1]);
	my @d=formulaAdd(\@b,\@c);
	return formula2Tex(\@d);
	}

sub formulaAddTermTex{
	my @a=@_;
	my @b=formulaTex2Hash($a[0]);
	my %c=formulaTex2HashTerm($a[1]);
	my @d=formulaAddTerm(\@b,\%c);
	return formula2Tex(\@d);
	}

sub formulaTex2Hash{
	my $t=$_[0];
	$t=~ s/\-/\+\-/g;
	$t=~ s/^\+//;
	my @t=split(/\+/,$t);
	my @r;
	for($i=0;$i<@t;$i++){
		my %t=formulaTex2HashTerm($t[$i]);
		$r[$i]=\%t;
		}
	return @r;
	}

sub formulaTerm2Tex{
	my %a=%{$_[0]};
	my $t="";
	my $k;
	foreach my $k ( sort keys %a ) {
#	while(my($k,$v)=each(%a)){
		my $v=$a{$k};
		if($k eq "#NUMBER#" and $v eq "1"){
			}elsif($k eq "#NUMBER#" and $v eq "-1"){
			$t="-".$t;
			}elsif($k eq "#NUMBER#" and $v eq "0"){
			$t=0;last;
			}elsif($k eq "#NUMBER#"){
			$t=$v." ".$t;
			}elsif($v eq "1"){
			$t.=$k;
			}elsif($v eq "0"){
			}elsif(length($v)==1){
			$t.=$k."^".$v." ";
			}else{
			$t.=$k."^{".$v."}";
			}
		}
	$t =~ s/\s+$//;
	if($t eq ""){$t="1";}
	return $t;
	}

sub formula2Tex{
	my @a=@{$_[0]};
	my $t="";
	for(my $i=0;$i<@a;$i++){
		my $p=formulaTerm2Tex($a[$i]);
		if($p ne "0"){
			$t.=$p." + ";
			}
		}
	$t=~ s/\+ \-/\- /g;
	chop $t;
	chop $t;
	chop $t;
	
	if($t eq ""){$t="0";}
	return $t;
	}

#標準関数
sub loadFile{
	local(@temp);
	open DATA,$_[0];
	flock(DATA, LOCK_EX);
	@temp = <DATA>;
	print <DATA>;
	flock(DATA, LOCK_NB); 
	close DATA;
	return join "",@temp;
}

sub saveFile{
	open DATA,">".$_[0];
	flock(DATA, LOCK_EX);
	print DATA $_[1];
	flock(DATA, LOCK_NB); 
	close DATA;
}
1