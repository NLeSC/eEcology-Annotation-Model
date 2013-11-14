function testcalcODBA()

x = [1 1 1 1 1]';
y = [2 2 2 2 2]';
z = [3 3 3 3 3]';

data = [x y z];

win_size = 3;
profile resume

out = calcODBA(data, win_size);

profile off
expected  = 4;
assertEqual(out, expected);