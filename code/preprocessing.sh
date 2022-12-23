folder="/home/ashik/Downloads/sample_1/Resampled"
for station in $folder/*
do
	echo $station
	for zevent in $station/*.HHZ.cut
	do
		revent=`echo $revent | awk -F"/" '{print $8}' | awk -v s=$station -F"." '{print s"/"$1"."$2"."$3"."substr($4,1,2)"R""."$5"."$6"."$7"."$8"."$9"."$10"."$11}'`
		tevent=`echo $tevent | awk -F"/" '{print $8}' | awk -v s=$station -F"." '{print s"/"$1"."$2"."$3"."substr($4,1,2)"T""."$5"."$6"."$7"."$8"."$9"."$10"."$11}'`
		echo $zevent $revent $tevent  
		if [ -z $revent ] || [ -z $tevent ]
		then
			echo "n"
		else 
			delta_z=`saclst delta f $zevent | awk '{print $2}'`
			delta_t=`saclst delta f $tevent | awk '{print $2}'`
			delta_r=`saclst delta f $revent | awk '{print $2}'`

			e_z=`saclst e f $zevent | awk '{print $2}'`
			e_r=`saclst e f $revent | awk '{print $2}'`
			e_t=`saclst e f $tevent | awk '{print $2}'`

sac<<!
r $zevent $revent $tevent
cut b 0 150
r 
cut off
wh
writeover
q
!


		    fi

	break
	done
	
break	
done
