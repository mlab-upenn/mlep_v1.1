function [userdata] = predictData(userdata)
load ./MATfiles/Prediction.mat
data = result;
days = 4;
time = 1440-1;
variables = size(data,2);
predictData = zeros(time+1,variables);

for i=1:variables
   % Each Day
   start = 1;
   for j = 1:days
       predictData(:,i) = predictData(:,i) + data(start:start+time,i);
       start = start + time + 1;
   end
   predictData(:,i) = predictData(:,i)/days; 
end

userdata.predictData = predictData;

