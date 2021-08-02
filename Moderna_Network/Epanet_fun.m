function [node_time_pressure,flow] = Epanet_fun(t,obj,Alpha,Demands,uncertunity)

obj.openHydraulicAnalysis;
obj.initializeHydraulicAnalysis;

a=1-uncertunity; b=1+uncertunity;
Alpha2=Alpha.*(a + (b-a).*randn(1,length(Alpha)));
sumAlpha=sum(Alpha2);

for b=1:obj.NodeCount
    Alpha2(b) = Alpha2(b)./sumAlpha;
end

BaseDemand = cell(length(obj.NodeBaseDemands),1);
for b=1:obj.NodeCount
    BaseDemand{1,1}(b) = Alpha2(b)*Demands(t);
end
obj.setNodeBaseDemands(BaseDemand);

obj.runHydraulicAnalysis;
node_tp=obj.getNodeHydaulicHead;
node_time_pressure(:,:)=node_tp';

flow=obj.getLinkFlows(1);
obj.nextHydraulicAnalysisStep;

obj.closeHydraulicAnalysis;
end


