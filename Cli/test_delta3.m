function delta = test_delta3 (x, u)
    y = x(1); pi = x(2); i = x(3); q = x(4);
    
    delta = [...
        -0.2*y-0.5*(i-pi)+0.2*q;
        0.4*y;
        u;
        i-pi];
end