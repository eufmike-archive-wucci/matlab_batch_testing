for x=1:5
    ['y' num2str(x)] = num2str(x^2);
    %ynum2str(x) = num2str(x^2);
    %eval(['y',num2str(x),'=',num2str(x^2),';'])
end