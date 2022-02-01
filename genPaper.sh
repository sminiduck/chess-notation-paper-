#!/bin/bash



#variables
FILE=$1
	information=""
	notation=""
		result=""
		num_item=0
		white=()
		black=()
		table=""


OUTPUT=$2
mode=0


#inputing information, notation
while read line || [ -n "$line" ];
do
	if [ "${line}" = "" ]; then
		mode=1
	elif [ $mode -eq 0 ]; then
		#mode0
		information+="$(echo $line | cut -d " " -f 1 | cut -c 2-): "
		information+="$(echo $line | cut -d " " -f 2- | cut -d "\"" -f 2)\\\\\ \n"
	else
		#mode1
		notation+="${line} "
	fi
	

done < "${FILE}"
echo "[information]"
information=$(echo -e $information)
echo "[notation]"
echo $notation
echo ""




#inputing W/B array for table
for item in $notation
do
	let num_item+=1
	mode=`expr $num_item % 3`

	if [ $mode = 2 ]; then
		white+=($item)
	elif [ $mode = 0 ]; then
		black+=($item)
	fi	
done
echo "[item]"
echo $num_item
echo ""
echo "[white]"
echo "${white[*]}"
echo""




#inputing table
result=$(echo $notation | rev | cut -d " " -f 1 | rev)
stopR=`expr $num_item % 3`
end=`expr '(' $num_item - 1 ')' / 3 - $stopR`
if [ $result = "1/2-1/2" ]; then
	result="½-½"
fi


echo "[result]"
echo $result
echo ""
echo "[stopR]"
echo $stopR
echo ""
echo "[end]"
echo $end
echo ""

for row in $(seq 0 31)
do
	for column in $(seq 0 8)
	do
		mode=`expr $column % 3`
		cur=`expr '(' $row \* 9 + $column ')' / 3`
		
		if [ $cur -le $end ];then
			if [ $column = 8 ]; then
				table+=" ${black[$cur]}"
			else
				  if [ $mode = 0 ]; then
					table+=" `expr $cur + 1` &"
				elif [ $mode = 1 ]; then
					table+=" ${white[$cur]} &"
				elif [ $mode = 2 ]; then
					table+=" ${black[$cur]} &"
				fi
			fi
		elif [ $stopR = 1 ] && [ `expr $cur - 1` = $end ] && [ $mode = 1 ]; then
			table+="$result &"

		elif [ ! $column = 8 ]; then
			table+=" &"	
		fi	
	done
	table+="\\\\\ \\hline\n"
done

echo "[table]"
table=$(echo -e $table)
echo "$table"
echo ""




#inputing picture
mid=`expr '(' 20 + $end ')' \* 2 / 5`
addR=3
if [ $stopR = 0 ]; then
	addR=2
fi
pos=()

pos[0]="$(echo "$(echo $notation | cut -d " " -f 1-54)" )"
pos[1]="$(echo $notation | cut -d " " -f 55-60)"
pos[2]="$(echo $notation | cut -d " " -f 61-`expr 3 \* $mid`)"
pos[3]="$(echo $notation | cut -d " " -f `expr 3 \* $mid + 1 `-`expr 3 \* $mid + 6`)"
pos[4]="$(echo $notation | cut -d " " -f `expr 3 \* $mid + 7`-`expr 3 \* $end - 3`)"
pos[5]="$(echo $notation | cut -d " " -f `expr 3 \* $end - 2`-`expr 3 \* $end + $addR`)"
#stopR = 1 > adding result


echo "${pos[*]}"


mkdir ./$OUTPUT
touch ./$OUTPUT/$OUTPUT.tex

#Writing LaTex
cat <<_EOF_ > ./${OUTPUT}/$OUTPUT.tex


\documentclass[a4paper]{article}

\usepackage{geometry}
\geometry{
 a4paper,
 left=10mm,
 right=10mm,
 top=20mm,
 bottom=5mm
}

\usepackage{flowfram}
\usepackage{microtype}
\usepackage{array}
\newflowframe[1-5]
{0.60\textwidth}{\textheight}
{0pt}{0pt}[leftcolumn]

\newflowframe[1-5]{0.30\textwidth}{\textheight}
{0.65\textwidth}{0pt}[rightcolumn]

\newcolumntype{n}{>{\centering\arraybackslash} m{0.4cm}}
\newcolumntype{s}{m{1cm}}
\renewcommand{\arraystretch}{1.2}

\usepackage{graphicx}
\usepackage[utf8]{inputenc}
\usepackage[english]{babel}
\usepackage{skak}

\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{Chess Notation}
\rhead{made by Jeong Seung Min}
\lhead{made from Tex Live, Bash}
\rfoot{Page \thepage}




\begin{document}


\section{Information}
${information}


\section{Notation}
\begin{table}[h]
\centering
\begin{tabular}{|n|s|s|n|s|s|n|s|s|}
\hline
${table}
\end{tabular}
\end{table}



\newpage


\section{picture}
\begin{center}
\medskip
\newgame

\vphantom{
\mainline{${pos[0]}}
}

\mainline{${pos[1]}}

\showboard

\vspace{30pt}

\vphantom{
\mainline{${pos[2]}}
}
\newline

\mainline{${pos[3]}}

\showboard

\vspace{30pt}

\vphantom{
\mainline{${pos[4]}}
}
\newline

\mainline{${pos[5]}}

\showboard

\end{center}


\end{document}


_EOF_


cd ./$OUTPUT
pdflatex.exe ./$OUTPUT.tex















