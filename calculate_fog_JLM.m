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

% create the plot - return the handle to the figure
f1 = figure;
set(gcf,'position',[100 100 650 550])

% plot the x data vs. time
subplot(4,1,1)
plot(d.Time,d{:,xVars},'LineWidth',2);
legend(xVars)
xlabel("Time, Seconds")
ylabel("X, mm")

% plot the z data vs. time
subplot(4,1,2:4)
zPlots = plot(d.Time,d{:,zVars},'LineWidth',2);
legend(zVars)
xlabel("Time, Seconds")
ylabel("Z, mm")

% isolate the variables that we will perform frequency analysis on
zVars = ["R_Heel_Z" "L_Heel_Z"]'

% create a new figure
f2 = figure;
set(gcf,'position',[100 100 650 550])

% there are only two z variables now, but this can be expanded if needed
nr = length(zVars);
% pre-allocating handles for graphics objects is always good practice
ax = gobjects(nr,1);

% loop through the (2) variables and make a plot
for i = 1:nr
    % save the handle to the subplot - we will use it later
    ax(i) = subplot(nr,1,i);
    % calculate the spectrum
    p = pspectrum(d{:,zVars(i)},Fs,'spectrogram','OverlapPercent',99,'MinThreshold',-10,'FrequencyResolution',1,'Reassign',true);
    % call "pspectrum" to draw the spectrum; for speed we could consider moving
    % the plotting code out into its own loop as it would not run on the cluster.
    pspectrum(d{:,zVars(i)},Fs,'spectrogram','OverlapPercent',99,'MinThreshold',-10,'FrequencyResolution',1,'Reassign',true);
    % I don't find colorbars super instructive
    colorbar(ax(i),'off')
    title(zVars(i))
    ylim([0 maxFreq])
    
    % superimpose the time-varying power
    hold on
    p = bandpowerwrapper(d{:,zVars(i)},Fs,Frange,250);
    h = plot(d.Time,p*maxFreq/maxProp,'r','clipping','on','LineWidth',4);

    % this will break if the above code is modified, so be careful - it is preferable
    % to access elements by name. however, all it is doing is copying the color of the
    % earlier plots to the current plot.
    set(h,'color',zPlots(i+3).Color)
    legend(h,zVars(i)+" Freeze Band Power (nu)")
end

% linkaxes is very useful - sets the x and y limits of the subplots to be equal. 
linkaxes(ax)

end
