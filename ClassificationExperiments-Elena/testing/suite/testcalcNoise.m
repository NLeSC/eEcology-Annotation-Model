function test_suite = testcalcNoise
initTestSuite;

function testcalcNoise_Func

x = [1 1 1 0 2]';
y = [2 2 5 2 2]';
z = [3 4 3 3 3]';

data = [x y z];

profile resume

out = calcNoise(data);

profile off
expected  = [2.5000   13.5000    1.2500   17.2500    0.7500    1.5000    0.5000];
assertEqual(out, expected);

function testcaclNoise_emptyInput

data = [];

profile resume

assertExceptionThrown(@() calcNoise(data), 'MATLAB:badsubscript','Empty input!');
    
profile off