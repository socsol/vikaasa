% This function is used to model the fisheries example given by Bene et al.
% (2001), in which there is a coupled "profitability" constraint:
function exited = bene_exited_fn2(posn, constraint_set)
    p = 8;
    q = 0.5;
    C = 100;
    c = 10;
    
    x = posn(1);
    e = posn(2);
    
    if (p*q*e*x - c*e - C < 0)
        exited = 0;
    else
        exited = vk_exited(posn, constraint_set);
    end
