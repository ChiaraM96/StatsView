function beta = beta_index(SCL, HR)

%input: Skin Conductance Level and Heart Rate after z-score 

EI=NaN;
SCL = zscore(SCL);
HR = zscore(HR);

if isequal(HR, zeros(size(HR)))
    return;
end


%define theta using 4-quadrant inverse tangent: According to
%Vecchiato's paper, HR is the HORIZONAL axes while GSR is the
%VERTICAL axes. atan2 syntax is atan2(vertical, horizzontal)
theta=atan2(SCL, HR);
% theta [-pi pi] like explained in the paper ()
%that says: " the angle b is defined in order to transform
%the domain of thet from [-p, p] to [0, 2 p] and to obtain the EI varying
%between -1 and 1

beta=(pi/2)-theta;

for i=1:length(SCL)
    if SCL(i)>=0 && HR(i)<=0
        beta(i)=(2.5*pi)-theta(i);
    end
end

EI_temp=1-(beta/pi);

EI=EI_temp;

end