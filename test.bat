@echo off
echo qc.pl�����s���B
echo in.txt���out.tex���쐬���Ă��܂��B
echo ...

qc.pl in.txt > out.tex

echo qc.pl���I�����܂����B
echo out.tex����out.dvi�����s���Ă��܂��B
echo ...

platex out.tex

echo out.dvi���쐬���܂����B
echo out.dvi����out.pdf���쐬���Ă��܂��B
echo ����out.pdf���J���Ă���ꍇ�͕��Ă��������B
pause
echo ...

dvipdfmx out.dvi

echo out.pdf���쐬���܂����B
echo out.pdf���J���Ă��܂��B
echo ...

start out.pdf
