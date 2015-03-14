require "math.pl";
use Encode 'encode';

print texTemplateQC($ARGV[0]);

sub texTemplateQC{
	my $fn=$_[0];
	my $h=<<HEAD;
\\documentclass[a4j,12pt]{jarticle}
\\begin{document}
HEAD
	
	my $m=<<MIDDLE;

\\subsection{状態遷移}

MIDDLE

	my $t=<<TAIL;
\\end{document}
TAIL
	#return encode('Shift_JIS',$h.texTemplateQCMap($fn).$m.execQC(loadFile($fn)).$t);
	return $h.texTemplateQCMap($fn).$m.execQC(loadFile($fn)).$t;
	}

sub texTemplateQCMap{
	my $fn=$_[0];
	my $h=<<H;
\\subsection{量子回路図}

\\setlength{\\unitlength}{1.0mm}
\\begin{picture}(100, 50)(0,0)
H
	my $t=<<T;
\\end{picture}

T
	return $h.drawQCMap(loadFile($fn)).$t;
	}


#量子コンピュータアセンブリを実行。
sub execQC{
	my @arg=@_;
	my $s=$arg[0];
	my @l=();
	#@lはラインの初期状態リスト。
	my %n=();
	#@lはラインの番号のハッシュ。
	my $a=0;
	#$aは実行中のステップ
	my @k=();
	#@kはラインの状態。長さ2の配列のリスト。
	my @h=();
	#@hはラインの状態の組み合わせの値。(|000>の状態,|001>の状態,|010>…)の値。
	my @e;
	#@eはエンタングルメントの状態リスト。表示用。エンタングルの無いラインは未定義、あるラインは1。
	my ($t0,$t1);
	#$t0はUNDEFの定義。$t1は結果。texのテキスト。
	my @q=();
	#@qは場合分け毎のラインの状態の組み合わせ値のリスト。
	my $l=0;
	#$lは量子ライン数。
	my @w=();
	#@wは古典ラインの番号のハッシュ。
	my $w=0;
	#$wは古典ラインの本数のカウント。
	
	my $i=0;
	$s=~ s/\r//g;
	$s=~ s/^\#.*$//mg;
	$s=~ s/^DEF (\S+) (.+)$/push(@l,$2);$n{$1}=$i;$i++;""/meg;
	$s=~ s/^\n//mg;
	$l=@l;
	
	#初期状態の展開
	my $j=0;
	for(my $i=0;$i<@l;$i++){
		my @a;
		if($l[$i] eq "0"){@a=("1","0");}
		elsif($l[$i] eq "1"){@a=("0","1");}
		elsif($l[$i] eq "UNDEF"){
			my $temp=("c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u")[$j];
			@a=($temp."_0",$temp."_1");
			$t0.="\\begin{equation}\n\\left|\\psi_{$j}\\right>=".$temp."_0\\left|0\\right>+".$temp."_1\\left|1\\right>\n\\end{equation}\n\n";
			$j++;
			}
		$k[$i]=\@a;
		}
	
	#それをさらに展開。
	for(my $i=0;$i<(2**(0+@l));$i++){
		my $a="1";
		for(my $j=0;$j<@l;$j++){
			$a=formulaExpandTex($a,${$k[$j]}[(int($i/(2**$j)))%2]);
			}
		$h[$i]=$a;
		}
	$q[0]=\@h;
	
	#ゲート用行列
	my %g;
	$s=~ s/^SET (\S) (\-?\d+) (\-?\d+) (\-?\d+) (\-?\d+)$/my @x=([$2,$3],[$4,$5]);$g{$1}=\@x;$i++;""/meg;
	$s=~ s/^\n//mg;
	my @x=([0,1],[1,0]);
	$g{"X"}=\@x;
	my @x=([0,"-i"],["i",0]);
	$g{"Y"}=\@x;
	my @x=([1,0],[0,-1]);
	$g{"Z"}=\@x;
	my @x=([1,1],[1,-1]);
	$g{"H"}=\@x;
	
	#実行部
	my @s=split(/\n/,$s);
	for(my $i=0;$i<@s;$i++){
		$t1.=execQCStateMultiCase(\@q,$l,$i,$w);
		my @d=split(/ /,$s[$i]);
		if($d[0] =~/^(\w)GATE$/){
			#ゲート通過
			my $gn=$1;
			my @gt=@{$g{$gn}};
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
				#下不要？
				if($e[$n{$d[1]}]!=1){@{$a[$n{$d[1]}]}=matrixMul($g{$gn},$a[$n{$d[1]}]);}
				for(my $j=0;$j<@h;$j++){
					$y[$j]=formulaAddTex(
						formulaExpandTex(
							$gt[int($j/(2**$n{$d[1]}))%2][0],
							$h[int($j/(2**($n{$d[1]}+1)))*(2**($n{$d[1]}+1))
							+$j%(2**$n{$d[1]})])
						,formulaExpandTex(
							$gt[int($j/(2**$n{$d[1]}))%2][1],
							$h[int($j/(2**($n{$d[1]}+1)))*(2**($n{$d[1]}+1))
							+$j%(2**$n{$d[1]})+(2**$n{$d[1]})]));
					}
				$q[$k]=\@y;
				}
			}elsif($d[0] eq "BFE"){
			#ビットフリップエラー
			my $gn=$1;
			my @gt=@{$g{$gn}};
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
				for(my $j=0;$j<@h;$j++){
					$y[$j]=$h[int($j/(2**($n{$d[1]}+1)))*(2**($n{$d[1]}+1))
							+$j%(2**$n{$d[1]})+((2**$n{$d[1]})*((1+(int($j/(2**$n{$d[1]}))%2))%2))];
					}
				$q[$k]=\@y;
				}
			}elsif($d[0] eq "IFE"){
			#位相フリップエラー
			my $gn=$1;
			my @gt=@{$g{$gn}};
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
				for(my $j=0;$j<@h;$j++){
					if(($j/(2**$n{$d[1]}))%2==1){$y[$j]=formulaExpandTex("-1",$h[$j]);}
					else{$y[$j]=$h[$j];}
					}
				$q[$k]=\@y;
				}
			}elsif($d[0] eq "OBS"){
			#観測時の振る舞い。
			my @s;
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				for(my $b=0;$b<=1;$b++){
					my @y;
					for(my $j=0;$j<@h;$j++){
						if(int($j/(2**$n{$d[1]}))%2 == $b){
							$y[int($j/(2**$n{$d[1]})/2)*(2**$n{$d[1]})+($j%(2**$n{$d[1]}))]=
								$h[$j];
							}
						}
					$s[int($k+$b*(2**$w))]=\@y;
#					$s[$k*2+$b]=\@y;
					}
				}
			$w{$d[1]}=$w;
			$w++;
			$l--;
			my %nn;
			my $m=$n{$d[1]};
			while(my($k,$v)=each(%n)){
				if($v>$m){$nn{$k}=$v-1;}else{$nn{$k}=$v;}
				}
			%n=%nn;
			@q=@s;
			}elsif($d[0] eq "CNOT"){
			#CNOT通過時の振る舞い。
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
				for(my $j=0;$j<@h;$j++){
					if(int($j/(2**$n{$d[1]}))%2 == 1){
						$y[$j]=$h[int($j/(2**$n{$d[2]})/2)*2*(2**$n{$d[2]})+
							($j%(2**$n{$d[2]}))+
							(int($j/(2**$n{$d[2]})+1)%2)*(2**$n{$d[2]})];
						}
					}
				$e[$n{$d[1]}]=1;
				$e[$n{$d[2]}]=1;
				$q[$k]=\@y;
				}
			}elsif($d[0]=~ /^C(\w)GATE$/){
			#コントロールユニタリゲート通過時
			#正常機能せず
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
				my $gn=$1;
				my @gt=@{$g{$gn}};
				if($e[$n{$d[1]}]!=1){@{$a[$n{$d[1]}]}=matrixMul($g{$gn},$a[$n{$d[1]}]);}
				for(my $j=0;$j<@h;$j++){
					#$h[$j](|$j>の係数)=ry;
					#int($j/(2**$d[1]))%2は$jの二進表示での$d[1]桁目。
					if(int($j/(2**$n{$d[1]}))%2 == 1){$y[$j]=formulaAddTex(formulaExpandTex($gt[int($j/(2**$n{$d[2]}))%2][0],$h[int($j/(2**($n{$d[2]}+1)))+$j%(2**$n{$d[2]})]),formulaExpandTex($gt[int($j/(2**$n{$d[2]}))%2][1],$h[int($j/(2**($n{$d[2]}+1)))+$j%(2**$n{$d[2]})+(2**$n{$d[2]})]))};
					}
				
				$e[$n{$d[1]}]=1;
				$e[$n{$d[2]}]=1;
				$q[$k]=\@y;
				}
			}elsif($d[0] eq "AND"){
			#古典量子ビットに対しAND演算を行うものです。古典ビットの用意が必要です。
			my @p=@q;
			for(my $k=0;$k<@q;$k++){
				if(int($k/(2**$w{$d[2]}))%2 ==1 and int($k/(2**$w{$d[3]}))%3 ==1){
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+(2**($d[1]))+($k%(2**$d[1]))]=$q[$k];
					}else{
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+($k%(2**$d[1]))]=$q[$k];
					}
				}
			}elsif($d[0] eq "OR"){
			#古典量子ビットに対しOR演算を行うものです。古典ビットの用意が必要です。
			my @p=@q;
			for(my $k=0;$k<@q;$k++){
				if(int($k/(2**$w{$d[2]}))%2 ==1 or int($k/(2**$w{$d[3]}))%3 ==1){
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+(2**($d[1]))+($k%(2**$d[1]))]=$q[$k];
					}else{
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+($k%(2**$d[1]))]=$q[$k];
					}
				}
			}elsif($d[0] eq "NOT"){
			#古典量子ビットに対しNOT演算を行うものです。古典ビットの用意が必要です。
			my @p=@q;
			for(my $k=0;$k<@q;$k++){
				if(int($k/(2**$w{$d[2]}))%2 ==0){
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+(2**($d[1]))+($k%(2**$d[1]))]=$q[$k];
					}else{
					$p[int($k/(2**($d[1]+1)))*(2**($d[1]+1))+($k%(2**$d[1]))]=$q[$k];
					}
				}
			}elsif($d[0]=~ /^CC(\w)GATE$/){
			#古典コントロールユニタリゲート通過時
			for(my $k=0;$k<@q;$k++){
				my @h=@{$q[$k]};
				my @y=@h;
#				for ($l=1;$l<@d-1;$l++){if(int($k/(2**$w{$d[1]}))%2 ==1){$tt++;}
				if(int($k/(2**$w{$d[1]}))%2 ==1){
					my $gn=$1;
					my @gt=@{$g{$gn}};
					if($e[$n{$d[2]}]!=1){@{$a[$n{$d[2]}]}=matrixMul($g{$gn},$a[$n{$d[2]}]);}
					for(my $j=0;$j<@h;$j++){
						#$h[$j](|$j>の係数)=ry;
						#int($j/(2**$d[1]))%2は$jの二進表示での$d[1]桁目。
						$y[$j]=formulaAddTex(
							formulaExpandTex(
								$gt[int($j/(2**$n{$d[2]}))%2][0],
								$h[int($j/(2**($n{$d[2]}+1)))*(2**($n{$d[2]}+1))
								+$j%(2**$n{$d[2]})])
							,formulaExpandTex(
								$gt[int($j/(2**$n{$d[2]}))%2][1],
								$h[int($j/(2**($n{$d[2]}+1)))*(2**($n{$d[2]}+1))
								+$j%(2**$n{$d[2]})+(2**$n{$d[2]})]));
						}
					$e[$n{$d[1]}]=1;
					$e[$n{$d[2]}]=1;
					$q[$k]=\@y;
					}
				}
			$e[$n{$d[2]}]=1;
			}
		#TODO:エンタングルメントを考慮
		}
	$t1.=execQCStateMultiCase(\@q,$l,0+@s,$w);
	return "\n\\subsubsection{状態の定義}\n".$t0."\n\\subsubsection{状態遷移}\n".$t1;
	}

sub execQCStateMultiCase{
	my @q=@{$_[0]};
	my $a=$_[1];
	my $i=$_[2];
	my $w=$_[3];
	my $t="";
	if(0+@q==1){
		if($i==0){$t="初期状態\n\\begin{equation}\n".execQCState($q[0],$a)."\n\\end{equation}\n\n";}
		else{$t="\\begin{equation}\n\\left|\\Psi_{".($i)."}\\right>=".execQCState($q[0],$a)."\n\\end{equation}\n\n";}
	}else{
		$t.="\\begin{equation}\n\\left|\\Psi_{".($i)."}\\right>=\\left(\n\\begin{array}{lc}\n";
		for(my $j=0;$j<@q;$j++){
			if(grep($_ ne "0",@{$q[$j]})>0){
				$t.="Case_{".(getBin($j,$w))."}&".execQCState($q[$j],$a)."\\\\\n";
				}
			}
		$t.="\\end{array}\n\\right.\n\\end{equation}\n\n";
		}
	return $t;
	}

sub execQCState{
	my @h=@{$_[0]};
	my $n=$_[1];
	my $u="";
	my $b=0;
	for(my $j=0;$j<@h;$j++){
		if ($h[$j] ne "0" and $h[$j] ne ""){$b=formulaAddTex($b,formulaExpandTex($h[$j],$h[$j]));$u.=$h[$j]."\\left|".getBin($j,$n)."\\right> +";}
#		if ($h[$j] ne "0" and $h[$j] ne ""){$u.=$h[$j]."\\left|$j\\right> +";}
		}
	$u =~ s/\+\-/\-/g;
	chop $u;
	return "\\frac{1}{\\sqrt{\\mathstrut $b}}\\left(".$u."\\right)";
	}

sub getBin{
	my @a=@_;
	my $t="";
	for(my $i=0;$i<$a[1];$i++){$t=(int($a[0]/(2**$i))%2).$t;}
	return $t;
	}

sub drawQCMap{
	my $height=15;
	my $width=10;
	my $startX=10;
	
	my @arg=@_;
	my $s=$arg[0];
	my @l=();
	#@lはラインの初期状態リスト。
	my %n=();
	#@lはラインの番号のハッシュ。
	my @b;
	#@bはラインの命令リストのリスト。
	my @c;
	#@cは最新のそのラインの状態。Qは量子ライン、Nはラインなし、Cは古典ゲート。
	my $c="";
	#$cはコネクション相当のtex文字列。
	my $t="";
	#$tはゲート相当のtex文字列。
	my $a=0;
	
	$s=~ s/\r//g;
	$s=~ s/^\#.+$//mg;
	$s=~ s/^DEF (\S+) (.+)$/push(@l,$2);$n{$1}=0+@b;my @a;push(@b,\@a);push(@c,"Q");""/meg;
	$s=~ s/^SET (\S) (\-?\d+) (\-?\d+) (\-?\d+) (\-?\d+)$//mg;
	$s=~ s/^\n//mg;
	
	my @s=split(/\n/,$s);
	for(my $i=0;$i<@s;$i++){
		@b=drawQCMapSetB(\@b,\@c,$a);
		my @d=split(/ /,$s[$i]);
		if($d[0] =~/^(\w)GATE$/){
			${$b[$n{$d[1]}]}[$a]="GATE(".$1.")";
			}elsif($d[0] eq "OBS"){
			${$b[$n{$d[1]}]}[$a]="01GATE";
			$c[$n{$d[1]}]="C";
			}elsif($d[0] eq "AND"){
			}elsif($d[0] eq "OR"){
			}elsif($d[0] eq "NOT"){
			}elsif($d[0] eq "BFE"){
			${$b[$n{$d[1]}]}[$a]="ERR";
			}elsif($d[0] eq "IFE"){
			${$b[$n{$d[1]}]}[$a]="ERR";
			}elsif($d[0] eq "CNOT"){
			${$b[$n{$d[2]}]}[$a]="CNOT";
			$c.=drawQCConnection("CNOT",$width*$i+$width/2+$startX,$height*$n{$d[1]}+$height,$height*$n{$d[2]}+$height);
			}elsif($d[0]=~ /^C(\w)GATE$/){
			${$b[$n{$d[2]}]}[$a]="GATE(".$1.")";
			$c.=drawQCConnection("U",$width*$i+$width/2+$startX,$height*$n{$d[1]}+$height,$height*$n{$d[2]}+$height);
			}elsif($d[0]=~ /^CC(\w)GATE$/){
			${$b[$n{$d[2]}]}[$a]="GATE(".$1.")";
			$c.=drawQCConnection("U0",$width*$i+$width/2+$startX,$height*$n{$d[1]}+$height,$height*$n{$d[2]}+$height);
			}else{$a--;}
		$a++;
		}
	for($i=0;$i<@b;$i++){
		$t.=drawQCLine(\@{$b[$i]},$startX,$height*(1+$i));
		}
	
	
	return $t.$c.drawQCMapInitStat(\@l,height).drawQCMapStatList((0+@s),$startX,0,$width);
	}

sub drawQCMapInitStat{
	#初期状態リストを表示
	my @s=@{$_[0]};
	my $t="";
	my $height=$_[1];
	$j=0;
	
	for(my $i=0;$i<@s;$i++){
		if($s[$i] eq "0" or $s[$i] eq "1"){
			$t.="\\put(3,".(15*($i+1))."){\$\\left|$s[$i]\\right>\$}\n";
			}elsif($s[$i] eq "UNDEF"){
			$t.="\\put(3,".(15*($i+1))."){\$\\left|\\psi_$j\\right>\$}\n";
			$j++;
			}
		}
	return $t;
	}

sub drawQCMapStatList{
	#下の遷移図を表示。引数は(状態遷移の数,開始x座標,開始y座標,幅)。
	my @a=@_;
	my $t="";
	for(my $i=1;$i<=$a[0];$i++){
		$t.="\\put(".($a[1]+$a[3]*$i).",".($a[2])."){\$\\left|\\Psi_{$i}\\right>\$}\n";
		$t.="\\put(".($a[1]+$a[3]*$i).", ".($a[2]+6)."){\\vector(0, 1){7}}\n"
		#ここ怪しい
		}
	return $t;
	}

sub drawQCMapSetB{
	my @b=@{$_[0]};
	my @c=@{$_[1]};
	my $i=$_[2];

	for(my $j=0;$j<@b;$j++){
		if($c[$j] eq "Q"){
			${$b[$j]}[$i]="QLINE";
			}elsif($c[$j] eq "C"){
			${$b[$j]}[$i]="LINE";
			}else{
			${$b[$j]}[$i]="NONE";
			}
		}
	return @b;
	}

sub drawQCConnection{
	my ($type,$x0,$y0,$y1)=@_;
	my $y;
	#引数は(結合タイプ,結合元X座標,同Y,結合先Y座標)
	#結合タイプはCNOT:CNOT,U:ユニタリゲート,U0:古典制御ユニタリゲート,U1:古典制御ユニタリゲート(元が分岐していない)
	$r="";
	my $t=0;
	my $d=1;
	if($type ne "U1"){$r.="\\put($x0,$y0){\\circle*{1}}\n";}
	if($type eq "CNOT" and $y1>$y0){
		$y=$y1;
		$d=-1
		}elsif($type eq "CNOT" and $y1<$y0){
		$y=$y1;
		}elsif($type eq "U" and $y1>$y0){
		$y=$y1-2;
		$d=-1;
		}elsif($type eq "U" and $y1<$y0){
		$y=$y1+2;
		}elsif(($type eq "U0" or $type eq "U1") and $y1>$y0){
		$y=$y1-2;
		$d=-1;
		$t=1;
		}elsif(($type eq "U0" or $type eq "U1") and $y1<$y0){
		$y=$y1+2;
		$t=1;
		}
	if($t==0){
		return $r."\\put($x0,$y){\\line(0,$d){".abs($y0-$y)."}}\n\n";
		}else{
		return $r."\\thicklines\n\\put($x0,$y){\\line(0,$d){".abs($y0-$y)."}}\n\\thinlines\n\n";
		}
	}

sub drawQCLine{
	my @arg=@_;
	my %unit;
	
	$unit{"CNOT"}=<<UNIT;
\\put([X],[Y]){\\circle{6}}
\\put([X],[Y]){\\line(1,0){5}}
\\put([X],[Y]){\\line(-1,0){5}}
\\put([X],[Y]){\\line(0,1){3}}
\\put([X],[Y]){\\line(0,-1){3}}

UNIT
	
	$unit{"GATE"}=<<UNIT;
\\put([CALC:X-2],[CALC:Y-2]){\\framebox( 4, 4){\$[A]\$}}
\\put([CALC:X+2],[Y]){\\line(1,0){3}}
\\put([CALC:X-2],[Y]){\\line(-1,0){3}}

UNIT
	
	$unit{"01GATE"}=<<UNIT;
\\put([CALC:X-4],[CALC:Y-2]){\\framebox( 4, 4){0}}
\\put([X],[CALC:Y-2]){\\framebox( 4, 4){1}}
\\thicklines
\\put([CALC:X+4],[Y]){\\line(1,0){1}}
\\thinlines
\\put([CALC:X-4],[Y]){\\line(-1,0){1}}

UNIT
	
	$unit{"QLINE"}=<<UNIT;
\\put([X],[Y]){\\line(1,0){5}}
\\put([X],[Y]){\\line(-1,0){5}}
UNIT
	
	$unit{"QLINEEND"}=<<UNIT;
\\put([X],[Y]){\\line(-1,0){5}}
UNIT
	
	$unit{"01LINE"}=<<UNIT;
\\thicklines
\\put([X],[Y]){\\line(1,0){5}}
\\put([X],[Y]){\\line(-1,0){5}}
\\thinlines

UNIT
	
	$unit{"01LINEEND"}=<<UNIT;
\\thicklines
\\put([X],[Y]){\\line(-1,0){5}}
\\thinlines

UNIT

	$unit{"ERR"}="";

	
	my @list=@{$arg[0]};
	my $x=$arg[1];
	my $y=$arg[2];
	#引数は(\\@描画命令のリスト,開始X座標,開始Y座標)
	#描画命令は、CNOT:CNOTゲート,GATE(X);ユニタリゲート(ex.Xが"H"ならアダマールゲート),
	#01GATE:古典ゲート,QLINE:量子線,QLINEEND:量子線終端,LINE:古典線,LINEEND:古典線終端,その他:描画なし
	
	my $width=10;
	$x+=$width/2;
	my $r="";
	
	for(my $i=0;$i<@list;$i++){
		my $t="";
		if($list[$i] eq "CNOT"){
			$t=drawQCLineBasicConv($unit{"CNOT"},$x,$y);
			}elsif($list[$i] =~/GATE\((.*)\)/){
			my $temp=$1;
			$t=drawQCLineBasicConv($unit{"GATE"},$x,$y);
			$t =~ s/\[A\]/$temp/;
			}elsif($list[$i] eq "01GATE"){
			$t=drawQCLineBasicConv($unit{"01GATE"},$x,$y);
			}elsif($list[$i] eq "QLINE"){
			$t=drawQCLineBasicConv($unit{"QLINE"},$x,$y);
			}elsif($list[$i] eq "LINE"){
			$t=drawQCLineBasicConv($unit{"01LINE"},$x,$y);
			}elsif($list[$i] eq "QLINEEND"){
			$t=drawQCLineBasicConv($unit{"QLINEEND"},$x,$y);
			}elsif($list[$i] eq "LINEEND"){
			$t=drawQCLineBasicConv($unit{"01LINEEND"},$x,$y);
			}else{
			$t="\n";
			}
		$r.=$t;
		$x+=$width;
		}
	return $r;
	}
	
sub drawQCLineBasicConv{
	my $text=$_[0];
	my $x=$_[1];
	my $y=$_[2];
	
	$text =~ s/\[X\]/$x/g;
	$text =~ s/\[Y\]/$y/g;
	$text =~ s/\[CALC:([XY0-9\+\-\*\/]+)\]/simpleCalc($1,$x,$y)/eg;
	
	return $text;
	}
	
sub simpleCalc{
	my $text=$_[0];
	my $x=$_[1];
	my $y=$_[2];
	
	$text=~ s/X/$x/g;
	$text=~ s/Y/$y/g;
	
	while($text=~ /\([^\(\)]+\)/){
		$text=~ s/\(([^\(\)]+)\)/simpleCalc($1)/e ;
		}
	while($text=~ /\-?[\d\.]+\/\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\/(\-?[\d\.]+)/int($1\/$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\%\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\%(\-?[\d\.]+)/int($1%$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\*\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\*(\-?[\d\.]+)/int($1*$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\+\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\+(\-?[\d\.]+)/int($1+$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\-\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\-(\-?[\d\.]+)/int($1-$2)/e ;
	}
	return $text;
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
