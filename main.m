if exist('arduinoObj','var')
    arduinoObj = [];
end

load('Noise_Profile')
load('Calibrated_Wavelength')

port = serialportlist("available");
arduinoObj = serialport(port(end), 115200);
arduinoObj.flush();

numPixels = 1024;
plotData = 1:numPixels;

%wavelength = (1:numPixels)/numPixels * (700-400) + 400; %Replace this with calibration code

average_points = 20;
avgData = [];
avgPlotData = plotData;

f = figure('units','inch','position',[0,0,7,7], 'DefaultTextFontSize', 24);

p1 = bar(wavelength,plotData, 'facecolor', 'flat','LineStyle','none');

set(gca,'FontSize',24)

p1.YDataSource = "plotData";
p1.XDataSource = "wavelength";
p1.CData = wavelengthToRGB(wavelength);
title({'Measured', 'Sensor Output'}, 'FontSize', 36)
xlabel('Wavelength [nm]', 'FontSize', 24)
ylabel('Relative Intensity', 'FontSize', 24)
ylim([0 2500])
hold on

p2 = plot(wavelength,avgPlotData,"k:");
p2.YDataSource = "avgPlotData";
p2.XDataSource = "wavelength";


exposure = 5000;
txt = text(max(wavelength)-20,2400,"Exp: "+exposure+" \mus");

set(gca, 'XDir','reverse')

hold off

sendExposure(arduinoObj, exposure)

try
    while ishghandle(f)
        
        [plotData,rcvExposure] = readDataFromSpectrometer(arduinoObj, numPixels);
        plotData = flip(plotData);
        
        plotData = plotData-Noise;
        
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

arduinoObj = [];

function sendExposure(arduinoObj, exposure)

disp("sending exposure "+exposure)
arduinoObj.write(hex2dec("0C"), 'uint8')
arduinoObj.write(hex2dec("AB"), 'uint8')
arduinoObj.write(""+exposure, 'string')

end