%% ################ main_data_debora.m ################### %%
%{

This program is prepared to run the data generation to obtain the pressure
and flow of the Moderna Netwoek.
It is required that the EPANET-Matlab-Toolkit is downloaded:

https://github.com/OpenWaterAnalytics/EPANET-Matlab-Toolkit

and the folder must be added to the MATLAB path.

%}
% ############################################################# %

%% Toolkit initialization %%

clc;clear ;close all;
% addpath('EPANET-Matlab-Toolkit-master') % add the toolkit

if exist('d','var')
    d.unload
end

start_toolkit;
d = epanet('MOD.inp');

%% Generate scenarios %%
% Scenarios configuration %
%-------decision choices-------%
days=1;
Selected_Sensors = [14,30] ;


Percentage_uncertainty=1; % 0 - 100
Operating_Point=[2];

%leak
Magnitude_leak=50;
leak_variation= 0; % leak size may vary + - leak variation

% ------erd decision choices----
SimulationTime=24*days;

load Flow  %demand
% the time instant is 10 min and this code is to filtered to 1 hour -1 day
Flow_1D=zeros(0,24);
for i=1:24     % Hourly filterization
    Flow_1D(i) = mean(Flow((i-1)*6+1:i*6));
end
Flow_1D=Flow_1D;
%generating the flow data for the nº  of days
Flow=[];
a=1-0.02; b=1+0.02;
for i=1:days     
    Flow =[Flow  Flow_1D.*(a + (b-a).*randn(1,1)) ];
end

%----end scenario configuration
BaseDemand = cell(length(d.NodeBaseDemands),1);
for i=1:length(d.NodeBaseDemands)
    BaseDemand{i} = d.NodeBaseDemands{i};
end

Flow=Flow/max(Flow) * sum(BaseDemand{1,1});
%--Calculing Alfa's
Alpha=zeros(1,d.NodeJunctionCount);
for i=1:d.NodeCount
    Alpha(i) = BaseDemand{1, 1}(i)/sum(BaseDemand{1, 1});
end

%% Hydraulic analysis %%
%% No Leak
% PNL: Pressure non leak (nodes,time)
for t=1:SimulationTime
    [PNL_du(:,t),flow_n(t)] = Epanet_fun(t,d,Alpha,Flow,Percentage_uncertainty/100) ;
end
% flow_n***
plot(PNL_du(3,:));hold on
plot(PNL_du(1,:))
d.unload
return
%%  Leak **
Flow=[];
for i=1:days     % Hourly filterization    
    Flow =[Flow Flow_1D.*(a + (b-a).*randn(1,1)) ];
end

for t=1:SimulationTime
    [PL(:,t,:,:),flow_leak(t)] = Epanet_leak(t,d,Alpha,Flow,Magnitude_leak,leak_variation) ;
end
pressure_leak=PL(:,:,:,1);

plot(flow_leak)
for sp=1:2*Split_points_l_v + 1
    residual_leak(sp,:,:,:)= PL(:,:,:,sp) - P_predicted;
end
%residual_leak(Split_points_l_v,Selected_Sensors ,Operating_Point, nodes)
%% Unload library %%
d.unload

%% Plots
close all;
x=Selected_Sensors(1);y=Selected_Sensors(2);
color=rand(d.NodeJunctionCount,3);

figure
hold on
for z=1:N_uncertainty_in_demand
    plot(residual_noleak(x,:,z),residual_noleak(y,:,z),'rx');
    % residual_noleak(Selected_Sensors,Operating_Point, N_uncertainty_in_demand)
    hold on
end
str = sprintf('Approximate non-faulty residual set Nf= %d %%', Percentage_uncertainty);    title(str)
xlabel ('Pressure in node 14 [m]')
ylabel ('Pressure in node 30 [m]')


figure
hold on
for sp=1:2*Split_points_l_v+1
    for z=1:31
        for op=1:length(Operating_Point)
            plot(residual_leak(sp,x,op,z),residual_leak(sp,y,op,z),'x','color',color(z,:));
            %residual_leak(Split_points_l_v,Selected_Sensors ,Operating_Point, nodes)
            hold on
        end
    end
end
str = sprintf('Nominal residuals- leak %d  l/s ', Magnitude_leak);    title(str)
str = sprintf('Pressure in node  %d ', x); xlabel (str)
str = sprintf('Pressure in node %d ', y); ylabel (str)


figure
hold on
for z=1:31
    for j=1:N_uncertainty_in_demand
        for op=1:length(Operating_Point)
            plot(residual_leak(Split_points_l_v,x,op,z)+residual_noleak(x,:,j),residual_leak(Split_points_l_v,y,op,z)+residual_noleak(y,:,j),'x','color',color(z,:));
            %residual_leak(Split_points_l_v,Selected_Sensors ,Operating_Point, nodes)
        end
    end
end
for z=1:31
    text((residual_leak(Split_points_l_v,x,:,z)),(residual_leak(Split_points_l_v,y,:,z)+0.2),strcat('Leak',32,num2str(z)))
end
str = sprintf('Nominal residuals- leak %d  l/s ', Magnitude_leak);    title(str)
str = sprintf('Pressure in node  %d ', x); xlabel (str)
str = sprintf('Pressure in node %d ',y); ylabel (str)




