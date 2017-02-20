function out = stc(power, coef, max_dis, dis)
    if(dis > max_dis)
        out = 1;
    else
        out = 1 - (coef * (max_dis - dis).^power);
    end
end