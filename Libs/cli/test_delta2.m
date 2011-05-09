function delta = test_delta2 (x, u)
    y = x(1); pi = x(2); i = x(3);
    
    delta = [...
        -0.02*y - 0.35*(i - pi);
        0.002*y;
        u];
end