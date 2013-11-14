function testcalcNoise_emptyinput()

data = [];
profile resume

assertExceptionThrown(@() calcNoise(data), 'MATLAB:badsubscript','Empty input!');
    
profile off
