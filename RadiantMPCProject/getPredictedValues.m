function [userdata] = getPredictedValues(userdata,stepNumber)

if size(userdata.predictData,1) >= stepNumber+userdata.mpcobj.Ts*4
    % txSolar
    userdata.v(2:5,2) = userdata.predictData(stepNumber+userdata.mpcobj.Ts:userdata.mpcobj.Ts:stepNumber+userdata.mpcobj.Ts*4,5);
    % heat1
    userdata.v(2:5,4) = userdata.predictData(stepNumber+userdata.mpcobj.Ts:userdata.mpcobj.Ts:stepNumber+userdata.mpcobj.Ts*4,2);
    % heat2
    userdata.v(2:5,5) = userdata.predictData(stepNumber+userdata.mpcobj.Ts:userdata.mpcobj.Ts:stepNumber+userdata.mpcobj.Ts*4,3);
    % heat3
    userdata.v(2:5,6) = userdata.predictData(stepNumber+userdata.mpcobj.Ts:userdata.mpcobj.Ts:stepNumber+userdata.mpcobj.Ts*4,4);
    % outTemp
    userdata.v(2:5,1) = userdata.predictData(stepNumber+userdata.mpcobj.Ts:userdata.mpcobj.Ts:stepNumber+userdata.mpcobj.Ts*4,1);

end

    
end