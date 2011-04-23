function delta = test_delta (x, u)
    d = x(1); p = x(2);
    
    delta = [...
        0.05*d - p*d;
        u];
end