function [incomingData,exposure] = readDataFromSpectrometer(arduinoObj, numPixels)

while arduinoObj.NumBytesAvailable < 0
    sleep(0.01)
end
syncReceived = false;
while ~syncReceived
    if arduinoObj.read(1,'uint8') == hex2dec('AF') && arduinoObj.read(1,'uint8') == hex2dec('A6')
        syncReceived = true;
    elseif arduinoObj.read(1,'uint8') == hex2dec('EA') && arduinoObj.read(1,'uint8') == hex2dec('5A')
        disp(arduinoObj.readline())
    end
end
length = arduinoObj.read(1,'uint16');
dataNumPixels = (length-7)/2;

exposure = arduinoObj.read(1,'uint16');

if dataNumPixels ~= numPixels
    disp("Pixel counts do not match!")
end
incomingData = arduinoObj.read(numPixels,'uint16');
dataChecksum = arduinoObj.read(1,'uint8');

end