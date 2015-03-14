@echo off
echo qc.plを実行中。
echo in.txtよりout.texを作成しています。
echo ...

qc.pl in.txt > out.tex

echo qc.plが終了しました。
echo out.texからout.dviを実行しています。
echo ...

platex out.tex

echo out.dviを作成しました。
echo out.dviからout.pdfを作成しています。
echo 現在out.pdfを開いている場合は閉じてください。
pause
echo ...

dvipdfmx out.dvi

echo out.pdfを作成しました。
echo out.pdfを開いています。
echo ...

start out.pdf
