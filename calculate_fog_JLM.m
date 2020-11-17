function [R_HEEL_FOG, L_HEEL_FOG] = calculate_fog_JLM(f,plot_flag)

% if the argument is a string or char, treat it as a filename
if strcmp(class(f),'string')
    d = read_trc(f);
elseif strcmp(class(f),'char')
    d = read_trc(f);
else
    % else assume it is a table
    d = f;
end

% look at a small section
peek(d)

% consider just the first portion
maxTime = 30;
d = d(d.Time<maxTime,:);

% create a time-varying spectrum of the heel markers.
% isolate the time step and the sampling frequency.
dt = d.Time(2)-d.Time(1);
Fs = 1/dt;

% also set the maximum frequency to plot and the maximum proportion of the
% power spectral density to plot
maxFreq = 20;
% maximum proportion of total energy in freeze band
maxProp = 0.01;

% select frequency range
Frange = [5 15];

% calculate power
R_HEEL_FOG = nanmean(bandpowerwrapper(d{:,"R_Heel_Z"},Fs,Frange,250));
L_HEEL_FOG = nanmean(bandpowerwrapper(d{:,"L_Heel_Z"},Fs,Frange,250));

% do not continue unless the plot flag has been set
if ~plot_flag
    return
end

% select the variables to plot
xVars = ["Top_Head_X"]';
zVars = ["Top_Head_Z" "R_ASIS_Z" "L_ASIS_Z" "R_Heel_Z" "L_Heel_Z"]';

% create the plot
f1 = figure;
set(gcf,'position',[100 100 650 550])

subplot(4,1,1)
plot(d.Time,d{:,xVars},'LineWidth',2);
legend(xVars)
xlabel("Time, Seconds")
ylabel("X, mm")

subplot(4,1,2:4)
zPlots = plot(d.Time,d{:,zVars},'LineWidth',2);
legend(zVars)
xlabel("Time, Seconds")
ylabel("Z, mm")


zVars = ["R_Heel_Z" "L_Heel_Z"]'

f2 = figure;
set(gcf,'position',[100 100 650 550])

nr = length(zVars);
ax = gobjects(nr,1);

for i = 1:nr
    ax(i) = subplot(nr,1,i);
    p = pspectrum(d{:,zVars(i)},Fs,'spectrogram','OverlapPercent',99,'MinThreshold',-10,'FrequencyResolution',1,'Reassign',true);
    pspectrum(d{:,zVars(i)},Fs,'spectrogram','OverlapPercent',99,'MinThreshold',-10,'FrequencyResolution',1,'Reassign',true);
    colorbar(ax(i),'off')
    title(zVars(i))
    ylim([0 maxFreq])
    
    hold on
    p = bandpowerwrapper(d{:,zVars(i)},Fs,Frange,250);
    h = plot(d.Time,p*maxFreq/maxProp,'r','clipping','on','LineWidth',4);

    % this will break if the above code is changed. need to access elements
    % by name.
    set(h,'color',zPlots(i+3).Color)
    legend(h,zVars(i)+" Freeze Band Power (nu)")
end

linkaxes(ax)



end