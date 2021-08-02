function [node_time_pressure,flow] = Epanet_leak(t,obj,Alpha,Demands,Magnitude_leak,leak_variation,Split_points_l_v)

obj.openHydraulicAnalysis;
obj.initializeHydraulicAnalysis;

aux_sp=Magnitude_leak-leak_variation;
aux_sum=-leak_variation/Split_points_l_v;
BaseDemand = cell(length(obj.NodeBaseDemands),1);
    
    for node=1:obj.NodeCount
        %Set new base demands (alphas) that include the leak
        F=zeros(obj.NodeCount,1);
    
        if node == 1
                aux_sum= aux_sum + leak_variation/Split_points_l_v;
        end  
        F(node)= aux_sum + aux_sp;
       
        %alpha = (F + (pattern - sum(F))*initial_demand)/pattern;
        alpha_f = (F + (Demands(t) - sum(F))*Alpha')/Demands(t);
        
        BaseDemand = cell(length(obj.NodeBaseDemands),1);
        for b=1:obj.NodeCount
            BaseDemand{1,1}(b) = alpha_f(b)*Demands(t);
        end
        
        obj.setNodeBaseDemands(BaseDemand);
        
        obj.runHydraulicAnalysis;
        node_tp=obj.getNodePressure;
        node_time_pressure(:,:,node)=node_tp;
        flow=obj.getLinkFlows(1);
        obj.nextHydraulicAnalysisStep;
    end
    

end



