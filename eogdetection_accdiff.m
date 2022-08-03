%----------------------------------------------------------------------
% [range window_acc_v ] = eogdetection_accdiff(data, min_windowwidth,, max_windowwidth threshold)
%
% a function to detect the range of eyeblink artifact by using MSDW method
% Version 2014.7.14
% Algorithm & Codes by Dr. Won-Du Chang
%
% Parameters
% data: It should be downsampled (we recommend 64 hz), median filter (medfilt1) should be applied in advance
% min_windowwidth/ max_windowwidth: the range of window size to calculate MSDW
%                                   We recommend [6 15] because usuall
%                                   eyeblink duration is 200~ 300 ms, and
%                                   it does not over 450 ms in our
%                                   experience.
%
% threshold: the criteron to decide whether a subsequence is the artifact or not. We recommend to use the twice value of the general threshold in amplitude threshold method
%            that is to say, if you think 75uV is general threshold to decide an artifact, you better to use 130~150 in our application
% msdw: If you want to use pre-caluclated MSDW, you can send it as a parameter to reduce calculating time
%
%
% Returns: range is the list of detected artifact, with following forms [r1_start r1_end; r2_start r2_end; ......;rn_start rn_end].
%         window_acc_v is for the reference, which is the list of the value of MSDW
%----------------------------------------------------------------------
% All rights are reserved by Won-Du Chang, ph.D, 
% CoNE Lab, Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [range, msdw ] = eogdetection_accdiff(data,  min_windowwidth, max_windowwidth,threshold, min_th_abs_ratio, msdw, windowSize4msdw)
    if nargin<5
        min_th_abs_ratio = 0.4;
    end
    
    %Multi SDW甫 拌魂茄促
    if nargin<6
        [ msdw, windowSize4msdw ] = calMultiSDW( data,  min_windowwidth, max_windowwidth );
    end

    
%     figure(1);
%     plot(msdw);
%     
    
    nRow = size(data,1);
    range_counter = 0;
    range = zeros(nRow,2);
    
    %for minmax_calculation
    indexes_localMin = zeros(ceil(nRow/2),1);
    indexes_localMax = zeros(ceil(nRow/2),1);
    nLocalMin = 0;
    nLocalMax = 0;
    LRValues_Spike =  zeros(ceil(nRow/2),2);
    LRWidths_Spike =  zeros(ceil(nRow/2),2);
    bAccept  =  zeros(ceil(nRow/2),1); 
    
    
    bTmpUp =0; bTmpDown = 0;    tmp_max_id= 0; tmp_min_id = 0;
    bMinFound = 0;
    
    

    for i=3:nRow
        if(msdw(i-1)>msdw(i-2) && msdw(i-1) == msdw(i))    % 上升
            tmp_max_id = i-1;
            bTmpUp = 1;     bTmpDown = 0;
        elseif(msdw(i-1)<msdw(i-2) && msdw(i-1) == msdw(i))  % 下降
            tmp_min_id = i-1;
            bTmpDown = 1;   bTmpUp = 0;
        elseif(msdw(i-1)==msdw(i-2))
            if(msdw(i-1) > msdw(i))
                if bTmpUp==1 

                    nLocalMax = nLocalMax+1;
                    indexes_localMax(nLocalMax) = round((i-1 + tmp_max_id)/2);

                end
                bTmpUp =0; bTmpDown = 0;
            elseif(msdw(i-1) < msdw(i)) 
                if bTmpDown==1
                    nLocalMin =  nLocalMin+1;
                    indexes_localMin(nLocalMin) = round((i-1 + tmp_min_id)/2);

                    bMinFound = 1;
                end
                bTmpUp =0; bTmpDown = 0;
            end 

        elseif(msdw(i-1)>msdw(i-2) && msdw(i-1) > msdw(i))
            nLocalMax = nLocalMax+1;
            indexes_localMax(nLocalMax) = i-1;

        elseif(msdw(i-1)<msdw(i-2) && msdw(i-1) < msdw(i))
            nLocalMin =  nLocalMin+1;
            indexes_localMin(nLocalMin) = i-1;
            bMinFound = 1;
        end

        if bMinFound ==1 && nLocalMax>0 
            id_min = indexes_localMin(nLocalMin);
            sum = msdw(indexes_localMax(nLocalMax)) - msdw(id_min);
            tmp_max_sum = sum;

            curmax_pos = indexes_localMax(nLocalMax);
            r_start = -1;
            
            
            LRValues_Spike(nLocalMin,:) = [msdw(indexes_localMax(nLocalMax)) msdw(id_min)];
            LRWidths_Spike(nLocalMin,:) = [windowSize4msdw(curmax_pos) indexes_localMax(nLocalMax)- id_min-indexes_localMax(nLocalMax)];

            bAccept(nLocalMin) = isCriteriaSatisfied(sum,threshold, min_th_abs_ratio, msdw(curmax_pos), msdw(id_min));%, id_min, curmax_pos, max_id_window_acc_v(id_min), nLocalMin-1, LRValues_Spike, LRWidths_Spike, bAccept);
            if(bAccept(nLocalMin)==1)    % 如果符合标准

                r_start = curmax_pos - windowSize4msdw(curmax_pos);
                if(range_counter>0 && r_start<=range(range_counter,2))
                    r_start = range(range_counter,2);
                end
            end

            for k=0:nLocalMax-1
                if(nLocalMax-1-k<=0 || indexes_localMin(nLocalMin)- indexes_localMax(nLocalMax-1-k)>max_windowwidth) 
                    break;
                end

                curmax_pos  = indexes_localMax(nLocalMax-1-k);                 
                prevmax_pos = indexes_localMax(nLocalMax-k);                   
                sum = sum + msdw(curmax_pos) - msdw(prevmax_pos); 

                r_start_tmp = curmax_pos - windowSize4msdw(curmax_pos);      


                tmp_check_result = isCriteriaSatisfied(sum,threshold,min_th_abs_ratio, msdw(curmax_pos), msdw(id_min));
                if(sum>tmp_max_sum  && (range_counter==0 || r_start_tmp>range(range_counter,1) ||r_start_tmp<=range(range_counter,1)) && tmp_check_result==1)
                
                    tmp_max_sum = sum;
                    if(range_counter==0 || r_start_tmp>=range(range_counter,2))  
                        r_start = r_start_tmp; 
                    end
                    
                    while(range_counter>0 && r_start_tmp<=range(range_counter,1))
                        range_counter = range_counter-1;                         
                        if(range_counter>0 && r_start_tmp<range(range_counter,2))
                            r_start = range(range_counter,2);                    
                        else
                            r_start = r_start_tmp;
                        end
                    end
                    bAccept(nLocalMin) =tmp_check_result;    
                    LRValues_Spike(nLocalMin,:) = [msdw(indexes_localMax(nLocalMax-1-k)) msdw(id_min)];
                    LRWidths_Spike(nLocalMin,:) = [windowSize4msdw(curmax_pos) indexes_localMax(nLocalMax-1-k)- id_min-indexes_localMax(nLocalMax-1-k)];
                end
            end
            
        

            if(r_start>0)
                range_counter = range_counter+1;
                range(range_counter,:) = [r_start id_min];
            end


            bMinFound = 0;

        end
    end
    
   
    %    delete unused memory (in the array of range)
    if range_counter<nRow
        range(range_counter+1:nRow,:)= [];
    end
end

function [bYes] = isCriteriaSatisfied(sum, threshold, min_th_abs_ratio, window_acc_v_max, window_acc_v_min)%, min_id,max_id,windowwidth_at_min, prev_minID,  LRValues_Spike, LRWidths_Spike, bAccept)
    bYes = (sum>threshold && window_acc_v_max>threshold*min_th_abs_ratio && window_acc_v_min<-threshold*min_th_abs_ratio);% && min_id - windowwidth_at_min>=max_id);
end


