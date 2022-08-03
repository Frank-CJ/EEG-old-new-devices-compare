function [ msdw, windowSize4msdw ] = calMultiSDW( data,  min_windowwidth, max_windowwidth )
    nRow = size(data,1);
    v_data = zeros(nRow,1);
    msdw = zeros(nRow,1);
    acc_v = zeros(nRow,1);  %vector accumulation
    

    windowSize4msdw = zeros(nRow,1);    % window size to achieve max value

    for i=2:nRow
        v_data(i) = data(i)- data(i-1);
        acc_v(i) = acc_v(i-1)+v_data(i);

        if(i==2)   %MSDW is not countable yet
            continue;
        end
        
        % calculate MSDW by changing window width
        % The two conditions are necessary (refer the article for detailed
        % description)
        max_abs_window_acc_v = 0; 
        sign_change_counter = 0;
        prev_sign = 0;
        sign = v_data(i);
        bBiggerDataFound    = 0;
        bSmallerDataFound   = 0;
        for j = 0:max_windowwidth-1
            if(i-j>0)
                sign = v_data(i-j);
            else
                break;
            end

            if(i-j-1>0)
                if(sign*prev_sign <0)
                    sign_change_counter = sign_change_counter+1;
                end
                

                if(v_data(i)<v_data(i-j))       
                    bBiggerDataFound = 1;   
                elseif(v_data(i)>v_data(i-j))   
                    bSmallerDataFound = 1;   
                end
                if bBiggerDataFound *bSmallerDataFound==1
                    break;
                end
            
                abs_win_acc_v = abs(acc_v(i) - acc_v(i-j-1));
                if (j>=min_windowwidth && abs_win_acc_v> max_abs_window_acc_v && mod(sign_change_counter,2)==0 && v_data(i)*v_data(i-j)>=0 )   %방향성이 맞고 min max 범위 내에 있는 것들 중 최대값 % bug_fixed. however, it should be checked again
                    max_abs_window_acc_v = abs_win_acc_v;
                    windowSize4msdw(i)= j+1;
                end
                if(sign~=0)
                    prev_sign = sign;
                end
            end
        end
        if windowSize4msdw(i)==0
            windowSize4msdw(i) = min_windowwidth;
        end
        
        if i-windowSize4msdw(i)-1>0
            msdw(i) = acc_v(i) - acc_v(i-windowSize4msdw(i));
        end
    end


end

