function output = BiSS_q( data, lambda , numscales, quad_mode )
%lambda=amount of detail suppression per scale
%iter=number of iterations (levels)
%quadmode = (0 = no quad fit, 1 = quad fit prior to scale, 2 = quad fit after scale)
w_max=5;
w_min=3;
datasize = size(data);
if length(datasize)<3
    output = zeros(datasize(1),datasize(2),numscales);
    base = data;
    for i = 1:numscales
%         strcat('scale',num2str(i),'...')
        w_curr = round(w_max-(i/numscales)*(w_max-w_min));
        if quad_mode==1
            base = quadricImg2(base,w_curr);
        end;
        base = bss( base, 5, lambda,[]);
        if quad_mode==2
            base = quadricImg2(base,w_curr);
        end;
        output(:,:,i)= base;
    end;    
else
    output = zeros(datasize(1),datasize(2),datasize(3),numscales);
    for j = 1:datasize(3)
        base = data(:,:,j);
        for i = 1:numscales
            w_curr = round(w_max-(i/numscales)*(w_max-w_min));
%             strcat('scale',num2str(i),'...')  
            if quad_mode==1
                base = quadricImg2(base,w_curr);
            end;
            base = bss( base, 5, lambda,[]);
            if quad_mode==2
                base = quadricImg2(base,w_curr);
            end;
            output(:,:,j,i)= base;
        end;
    end;     
end;

