if exist('arduinoObj','var')
    arduinoObj = [];
end

port = serialportlist("available");
arduinoObj = serialport(port(end), 115200);
arduinoObj.flush();

numPixels = 1024;
plotData = 1:numPixels;
pixels = 1:numPixels;

average_points = 100;
avgData = [];
avgPlotData = plotData;

f = figure();

p1 = bar(pixels,plotData, 'facecolor', 'flat','LineStyle','none');

p1.YDataSource = "plotData";
p1.XDataSource = "pixels";
title('Relative Intensity vs. Pixel')
xlabel('Pixel')
ylabel('Relative Intensity')
ylim([0 2500])
hold on

p2 = plot(pixels,avgPlotData,"k:");
p2.YDataSource = "avgPlotData";
p2.XDataSource = "pixels";

exposure = 5000;
txt = text(20,2400,"Exp: "+exposure+" \mus");

hold off

sendExposure(arduinoObj, exposure)

try
    while ishghandle(f)
        
        [plotData,rcvExposure] = readDataFromSpectrometer(arduinoObj, numPixels);
        plotData = flip(plotData);
        
        
        avgData(end+1,:) = plotData;
        
        if size(avgData,1)>average_points
            avgData(1,:) = [];
        end
        
        avgPlotData = mean(avgData);
        
        refreshdata
        set(txt,'String',"Exp: "+rcvExposure+" \mus")
        drawnow
    end
catch ME
end

plot(pixels, avgPlotData)
title('Relative Intensity vs. Pixel')
xlabel('pixels')
ylabel('Relative Intensity')

selection = questdlg('Use this profile?', 'Figure Closed', 'Yes', 'No', 'Yes');
switch selection
    case 'Yes'
      Noise = avgPlotData;
      save('Noise_Profile', 'Noise');
    case 'No'
end

clear arduinoObj
close all
