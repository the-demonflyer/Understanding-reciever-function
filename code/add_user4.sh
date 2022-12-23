folder="/home/ashik/Downloads/sample_1/Resampled"
for n in $folder/*
do
	for s in $n/*
	do
		for rf1 in $s
		do 
			echo $rf1
			#saclst user4 f $rf
			rf=`echo $rf1 | awk -F"/" '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7"/"$8}'`
			echo $rf
			gc=`saclst gcarc f $rf | awk '{print $2}'`
			evdp=`saclst evdp f $rf | awk '{print $2}'`
			ray_p=`udtdd -GCARC ${gc} -EVDP ${evdp}`
sac<<!
r $rf
ch USER4 $ray_p
wh
w over
q
!
		#break
		done
	#break
	done
#break
done
