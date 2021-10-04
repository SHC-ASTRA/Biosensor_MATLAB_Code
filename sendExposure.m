function sendExposure(arduinoObj, exposure)

disp("sending exposure "+exposure)
arduinoObj.write(hex2dec("0C"), 'uint8')
arduinoObj.write(hex2dec("AB"), 'uint8')
arduinoObj.write(""+exposure, 'string')

end