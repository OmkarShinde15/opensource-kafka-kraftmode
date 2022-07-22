for user in * ;do
   S=$(du -s $'/home' | awk '{print $1}')
    if  [[ $S -ge 5000 ]] ;then


         echo du -sh $user
   fi
done