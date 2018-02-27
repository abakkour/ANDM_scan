function generate_onsetlist(mu, n, triallength, numberoflists, outputroot)

onset=zeros(1,n-1);
for i=1:n-1
onset(i)=expsample(mu,1,12,.5);
end
mean(onset)

for l=1:numberoflists
    onsetlist=zeros(1,n);
    k=0;
    onsets=Shuffle(onset);
    for i=2:n
        k=k+triallength+onsets(i-1);
        onsetlist(i)=k;
    end
onsetlist=onsetlist+2;
save([outputroot '_' num2str(l) '.mat'], 'onsetlist');    
end