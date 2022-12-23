#square_root=$(echo $1 | awk '{print sqrt($1)}')

folder="Modified"
H=35
z=1

vp=6
vp_sq=`echo -e "scale=3;"$vp'*'$vp |bc`
vp_inv_sq=`echo -e "scale=3;"1'/'$vp_sq |bc`
#echo $vp_inv_sq

vs=3.1
vs_sq=`echo -e "scale=3;"$vs'*'$vs |bc`
vs_inv_sq=`echo -e "scale=3;"1'/'$vs_sq |bc`
#echo $vs_inv_sq

W=(0.6 0.3 0.1)

for station in $folder/BH*
do
	s=`echo $station | awk -F"/" '{print $2}'`

	#Create csv to stored shk for each station
	csv_file_name=$station"_Shk.csv"
	echo "wave,Shk" > $csv_file_name
	
	for files in $station/*.rf_w1.6
	do
		
		wave=`echo $files | awk -F"/" '{print $NF}'`
		echo $file
		p=`saclst user4 f $files | awk '{print $2}'`
		p_sq=`echo -e "scale=3;"$p'*'$p |bc`

		l_sq=`echo -e "scale=3;"$vs_inv_sq'-'$p_sq |bc`
		#echo $l_sq
		l=$(echo $l_sq | awk '{print sqrt($1)}')
		#echo $l

		r_sq=`echo -e "scale=3;"$vp_inv_sq'-'$p_sq |bc`
		#echo $r_sq
		r=$(echo $r_sq | awk '{print sqrt($1)}')
		#echo $r
		#echo $H

		t_ps=`echo -e "scale=3;"$l'*'$H'-'$r'*'$H |bc`
		t_ppps=`echo -e "scale=3;"$l'*'$H'+'$r'*'$H |bc`
		t_psps_a_ppss=`echo -e "scale=3;"$l'*'$H'+'$l'*'$H |bc`
		#echo $t_ps, $t_ppps, $t_psps_a_ppss

		delta=`saclst delta f $files | awk '{print $2}'`
		b=`saclst b f $files | awk '{print $2}'`
		e=`saclst e f $files | awk '{print $2}'`
		#echo $b,$e
	
		n1=`echo -e '(('$t_ps')-('$b'))/'$delta|bc`
		n2=`echo -e '(('$t_ppps')-('$b'))/'$delta|bc`
		n3=`echo -e '(('$t_psps_a_ppss')-('$b'))/'$delta|bc`
		N=($n1 $n2 $n3)
		#echo "N="${N[*]}
		
sac<<!
r $files
w alpha $files.txt
q
!

		amps=`cat $files.txt  | tail -n +31`
		#cat $files.txt 
		i=0
		n=0
		max_A=0
		for a in $amps
		do
			#echo $i , $a
			if (( ${N[$n]}<=$i ))
			then
				
				R[$n]=$a
				n=$((n+1))
				if [ $n -ge ${#N[*]} ]
				then
					break
				fi
			fi
			i=$((i+1))
			max_A=a
			
		done

		while [ ${#R[*]} != 3 ]
		do
			R[${#R[*]}]=max_A
		done
		#echo "R=" ${R[*]}

		S_hk=`python3 equations.py ${W[0]} ${R[0]} ${W[1]} ${R[1]} ${W[2]} ${R[2]}`
		
		#add data to csv
		echo $wave','$S_hk >> $csv_file_name
		rm $files.txt
		echo "Running " $s "........."
	
		
	done


done
